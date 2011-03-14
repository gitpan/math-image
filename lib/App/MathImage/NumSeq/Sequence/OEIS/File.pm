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

package App::MathImage::NumSeq::Sequence::OEIS::File;
use 5.004;
use strict;
use warnings;
use Carp;
use POSIX ();
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Array';

use vars '$VERSION';
$VERSION = 48;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('OEIS File');
sub description {
  my ($class_or_self) = @_;
  if (ref $class_or_self && defined $class_or_self->{'description'}) {
    return $class_or_self->{'description'};
  }
  return __('OEIS sequence from file.');
}
# use constant parameter_list =>
#   ({
#     name    => 'filename',
#     display => __('Filename'),
#     width   => 40,
#     type    => 'string',
#     default => '',
#    });

sub is_type {
  my ($self, $type) = @_;
  return $self->{'type_hash'}->{$type};
}

sub new {
  my ($class, %options) = @_;
  ### OEIS-File: %options

  my $oeis_number = $options{'oeis_number'};
  ### $oeis_number
  my $aref = _read_values($oeis_number);
  ### $aref
  my %info = _read_internal($oeis_number, $aref);
  if (! %info) {
    %info = _read_html($oeis_number, $aref);
  }
  $aref ||= delete $info{'array'};

  if (! $aref) {
    croak "B-file or HTML not found for A-number \"",$oeis_number,"\"";
  }

  if ($info{'type_hash'}->{'radix'}) {
    my $max = 0;
    foreach my $i (1 .. $#$aref) {
      if ($aref->[$i] > 50) {
        last;
      }
      if ($aref->[$i] > $max) {
        $max = $aref->[$i];
      }
    }
    $info{'values_max'} = $max;
    $info{'radix'} = $max+1;
  }

  return $class->SUPER::new (%info,
                             %options,
                             array => $aref);
}

sub oeis_dir {
  require File::Spec;
  require File::HomeDir;
  return File::Spec->catfile (File::HomeDir->my_home, 'OEIS');
}

my $max_value = POSIX::FLT_RADIX() ** (POSIX::DBL_MANT_DIG()-5);

sub num_to_bfile {
  my ($num, $prefix) = @_;
  $prefix ||= 'b';
  return sprintf '%s%06d.txt', $prefix, $num;
}

sub num_to_html {
  my ($num, $ext) = @_;
  $ext ||= '.html';
  return sprintf 'A%06d%s', $num, $ext;
}

sub _read_html {
  my ($num, $aref) = @_;
  my @ret;
  foreach my $basefile (num_to_html($num), num_to_html($num,'.htm')) {
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    if (open FH, "<$filename") {
      my $contents = do { local $/; <FH> }; # slurp
      close FH or die;

      my $anum = sprintf 'A%06d', $num;
      if ($contents =~
          m{$anum\n.*?<td valign="top" align="left">\s*(.*?)\s*<(br|/td)>}s) {
        my $description = $1;
        $description =~ s/\s+/ /g;
        $description =~ s/<.*?>//sg;
        $description =~ s/&lt;/</sg;
        $description =~ s/&gt;/>/sg;
        $description =~ s/&amp;/&/sg;
        $description .= "\n" . ($aref
                                ? __('Values from B-file')
                                : __('First few values from HTML'));
        push @ret, 'description', $description;
      }
      ### @ret

      if (! $aref) {
        # fragile grep out of the html ...
        $contents =~ s{>graph</a>.*}{};
        $contents =~ m{.*<tt>([^<]+)</tt>};
        my $list = $1;
        unless ($list =~ m{^([0-9,-]|\s)+$}) {
          croak "Oops list of values not found in ",$filename;
        }
        push @ret, 'array', [ split /[, \t\r\n]+/, $list ];
      }
      ### @ret
      return @ret;
    }
    ### no html: $!
  }
  return;
}

sub _read_values {
  my ($num) = @_;
  ### NumSeq-OEIS-File _read_values(): @_

  require File::Spec;
 PREFIX: foreach my $prefix ('a', 'b') {
    my $basefile = num_to_bfile($num,$prefix);
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    if (! open FH, "<$filename") {
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
    return \@array;
  }
  return;
}

sub _read_internal {
  my ($num, $aref) = @_;
  my @ret;
  my %type_hash = (integer => 1);
  my $basefile = num_to_html($num,'.internal');
  my $filename = File::Spec->catfile (oeis_dir(), $basefile);
  ### $basefile
  ### $filename
  if (! open FH, "<$filename") {
    ### no .internal: $!
    return;
  }
  my $contents = do { local $/; <FH> }; # slurp
  close FH or die "Error reading $filename: $!";;

  if ($contents =~ /^%K (.*?)(<tt>|$)/) {
    my %K;
    @K{split /[, \t]+/, $1} = ();
    if (exists $K{'nonn'}) {
      push @ret, values_min => 0;
    }
    if (exists $K{'base'} || exists $K{'cons'}) {
      $type_hash{'radix'} = 1;
    }
  }

  if ($contents =~ /^%N (.*?)(<tt>|$)/) {
    my $description = $1;
    $description =~ s/\s+/ /g;
    $description =~ s/<.*?>//sg;
    $description =~ s/&lt;/</sg;
    $description =~ s/&gt;/>/sg;
    $description =~ s/&amp;/&/sg;
    $description .= "\n" . ($aref
                            ? __('Values from B-file')
                            : __('First few values from HTML'));
    push @ret, description => $description;
  }

  if (! $aref) {
    $contents =~ /^%S (.*?)(<tt>|$)/
      or croak "Oops list of values not found in ",$filename;
    push @ret, 'array', [ split /[, \t\r\n]+/, $1 ];
  }

  push @ret, type_hash => \%type_hash;
  ### @ret
  return @ret;
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
