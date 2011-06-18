# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


# characteristic('monotonic')
#    from .internal sample values
#    otherwise reading whole B-File
#    subclass Sequence::File for b-file with extra info


package App::MathImage::NumSeq::Sequence::OEIS::File;
use 5.004;
use strict;
use Carp;
use POSIX ();
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Base::Array';
use App::MathImage::NumSeq::Sequence::OEIS;

use vars '$VERSION';
$VERSION = 60;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('OEIS File');
sub description {
  my ($class_or_self) = @_;
  if (ref $class_or_self && defined $class_or_self->{'description'}) {
    return $class_or_self->{'description'};
  }
  return __('OEIS sequence from file.');
}
*parameter_list = \&App::MathImage::NumSeq::Sequence::OEIS::parameter_list;

sub new {
  my ($class, %options) = @_;
  ### OEIS-File: %options

  my %self;
  if (my $anum = $options{'anum'}) {
    my $self = {};
    ### $anum
    _read_values (\%self, $anum);
    if (! _read_internal(\%self, $anum)) {
      _read_html(\%self, $anum);
    }
    if (! $self{'array'}) {
      croak 'B-file, Internal or HTML not found for A-number "',$anum,'"';
    }

    if ($self{'characteristic'}->{'radix'}) {
      my $aref = $self{'array'};
      my $max = 0;
      foreach my $i (1 .. $#$aref) {
        if ($aref->[$i] > 50) {
          last;
        }
        if ($aref->[$i] > $max) {
          $max = $aref->[$i];
        }
      }
      $self{'values_max'} = $max;
      $self{'radix'} = $max+1;
    }
  }

  return $class->SUPER::new (%self,
                             %options);
}

sub oeis_dir {
  require File::Spec;
  require File::HomeDir;
  return File::Spec->catfile (File::HomeDir->my_home, 'OEIS');
}

my $max_value = POSIX::FLT_RADIX() ** (POSIX::DBL_MANT_DIG()-5);

sub anum_to_bfile {
  my ($anum, $prefix) = @_;
  $prefix ||= 'b';
  $anum =~ s/^A/$prefix/;
  return "$anum.txt";
}

sub _read_values {
  my ($self, $anum) = @_;
  ### NumSeq-OEIS-File _read_values(): @_

  require File::Spec;
 PREFIX: foreach my $prefix ('a', 'b') {
    my $basefile = anum_to_bfile($anum,$prefix);
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    if (! open FH, "< $filename") {
      ### no bfile: $!
      next;
    }
    my @array;
    my $seen_good = 0;
    while (defined (my $line = <FH>)) {
      chomp $line;
      if ($line =~ /^\s*$/) {
        # ignore blank lines
      } elsif (my ($i, $n) = ($line =~ /^([0-9]+) (-?[0-9]+)[ \t]*$/)) {
        if ($n > $max_value) {
          ### stop at bignum value: $line
          last;
        }
        $seen_good = 1;
        $array[$i] = $n;
      } else {
        # allow random stuff in a.txt files, such as a084888.txt
        if (! $seen_good && $prefix eq 'a') {
          close FH or die "Error reading $filename: $!";
          next PREFIX;
        }
        die "oops, bad line in $filename: '$line'";
      }
    }
    close FH or die "Error reading $filename: $!";
    $self->{'filename'} = $filename;
    $self->{'array'} = \@array;
  }
  return;
}

sub _read_internal {
  my ($self, $anum, $aref) = @_;

  my $basefile = "$anum.internal";
  my $filename = File::Spec->catfile (oeis_dir(), $basefile);
  ### $basefile
  ### $filename
  if (! open FH, "<$filename") {
    ### no .internal file: $!
    return;
  }
  my $contents = do { local $/; <FH> }; # slurp
  close FH or die "Error reading $filename: ",$!;

  my %characteristic = (integer => 1);
  $self->{'characteristic'} = \%characteristic;

  my $offset;
  if ($contents =~ /^%O\s+(\d+)/) {
    $offset = $1;
  } else {
    $offset = 0;
  }

  my $description;
  if ($contents =~ /^%N (.*?)(<tt>|$)/) {
    $description = $1;
    $description =~ s/\s+/ /g;
    $description =~ s/<.*?>//sg;
    $description =~ s/&lt;/</sg;
    $description =~ s/&gt;/>/sg;
    $description =~ s/&amp;/&/sg;

    if ($description =~ /^number of /i) {
      $characteristic{'count'} = 1;
    }
    $description .= "\n" . (defined $self->{'filename'}
                            ? __x('Values from B-file {filename}',
                                  filename => $self->{'filename'})
                            : __('First few values from HTML'));
    $self->{'description'} = $description;
  }

  _set_characteristics ($self, $description,
                        $contents =~ /^%K (.*?)(<tt>|$)/ && $1);

  if (! $self->{'array'}) {
    $contents =~ m{^%S (.*?)(</tt>|$)}m
      or croak "Oops list of values not found in ",$filename;
    _split_sample_values ($self, $filename, $1, $offset);
  }
}

sub _read_html {
  my ($self, $anum) = @_;
  foreach my $basefile ("$anum.html", "$anum.htm") {
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    if (open FH, "< $filename") {
      my $contents = do { local $/; <FH> }; # slurp
      close FH or die;

      my $description;
      if ($contents =~
          m{$anum\n.*?
            <td[^>]*>\s*</td>   # blank <td ...></td>
            <td[^>]*>           # <td ...>
            \s*
            ([^>]+)             # text
            <(br|/td)>          # to <br> or </td>
         }sx) {
        $description = $1;
        $description =~ s/^\s+//;
        $description =~ s/\s+$//;
        $description =~ s/\s+/ /g;    # collapse whitespace
        $description =~ s/<.*?>//sg;
        $description =~ s/&lt;/</sg;
        $description =~ s/&gt;/>/sg;
        $description =~ s/&amp;/&/sg;
        $description .= "\n" . (defined $self->{'filename'}
                                ? __x('Values from B-file {filename}',
                                      filename => $self->{'filename'})
                                : __('First few values from HTML'));
        $self->{'description'} = $description;
      }

      # fragile grep out of the html ...
      my $offset = ($contents =~ /OFFSET.*?<tt>(\d+)/s
                    && $1);
      ### $offset

      # fragile grep out of the html ...
      my $keywords;
      if ($contents =~ m{KEYWORD.*?<tt[^>]*>(.*?)</tt>}s) {
        ### keywords match: $1
        ($keywords = $1) =~ s{</?span[^>]*>}{}g;
      }
      _set_characteristics ($self, $description, $keywords);

      if (! $self->{'array'}) {
        # fragile grep out of the html ...
        $contents =~ s{>graph</a>.*}{};
        $contents =~ m{.*<tt>([^<]+)</tt>};
        my $list = $1;
        _split_sample_values ($self, $filename, $list, $offset);
      }
      return;
    }
    ### no html: $!
  }
  return;
}

sub _set_characteristics {
  my ($self, $description, $keywords) = @_;
  ### _set_characteristics()
  ### $description
  ### $keywords

  foreach my $key (split /[, \t]+/, ($keywords||'')) {
    ### $key
    if ($key eq 'nonn') {   # non-negative
      $self->{'values_min'} = 0;
    }
    # "base" means dependent on some number base
    # "cons" means decimal expansion of a number
    if ($key eq 'base' || $key eq 'cons') {
      $self->{'characteristic'}->{'radix'} = 1;
    }
    if ($key eq 'cofr') {
      $self->{'characteristic'}->{'continued_fraction'} = 1;
    }
    $self->{'characteristic'}->{"OEIS_$key"} = 1;
  }
}

sub _split_sample_values {
  my ($self, $filename, $str, $offset) = @_;
  unless ($str =~ m{^([0-9,-]|\s)+$}) {
    croak "Oops unrecognised list of values not found in ",$filename,"\n",$str;
  }
  $self->{'array'} = [ split /[, \t\r\n]+/, $str ];

  # %O "OFFSET" is subscript of first number, or for digit expansions it's
  # the position of the decimal point
  # http://oeis.org/eishelp2.html#RO
  if ($offset && ! $self->{'characteristic'}->{'radix'}) {
    unshift @{$self->{'array'}}, (undef) x $offset;
  }
}

1;
__END__







  # foreach my $basefile (anum_to_html($anum), anum_to_html($anum,'.htm')) {
  #   my $filename = File::Spec->catfile (oeis_dir(), $basefile);
  #   ### $basefile
  #   ### $filename
  #   if (open FH, "<$filename") {
  #     my $contents = do { local $/; <FH> }; # slurp
  #     close FH or die;
  # 
  #     # fragile grep out of the html ...
  #     $contents =~ s{>graph</a>.*}{};
  #     $contents =~ m{.*<tt>([^<]+)</tt>};
  #     my $list = $1;
  #     unless ($list =~ m{^([0-9,-]|\s)+$}) {
  #       croak "Oops list of values not found in ",$filename;
  #     }
  #     my @array = split /[, \t\r\n]+/, $list;
  #     ### $list
  #     ### @array
  #     return \@array;
  #   }
  #   ### no html: $!
  # }
