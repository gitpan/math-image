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
$VERSION = 45;

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

sub type {
  my ($class_or_self) = @_;
  if (ref $class_or_self) {
    return $class_or_self->{'type'};
  }
  return $class_or_self->SUPER::type;
}

sub new {
  my ($class, %options) = @_;
  ### OEIS-File: %options

  my $oeis_number = $options{'oeis_number'};
  ### $oeis_number
  my $aref = _read_values($oeis_number);
  ### $aref
  my %info = _read_info($oeis_number, $aref);
  $aref ||= delete $info{'array'};

  if (! $aref) {
    croak "B-file or HTML not found for A-number \"",$oeis_number,"\"";
  }

  my $type = 'radix';
  my $max = 0;
  foreach my $i (1 .. $#$aref) {
    if ($aref->[$i] > 50) {
      $type = 'seq';
      last;
    }
    if ($aref->[$i] > $max) {
      $max = $aref->[$i];
    }
  }
  if ($type eq 'radix') {
    $options{'radix'} = $max+1;
  }

  return $class->SUPER::new (%info,
                             %options,
                             type => $type,
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

sub _read_info {
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
  foreach my $basefile (num_to_bfile($num,'a'), num_to_bfile($num)) {
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename

    if (open FH, "<$filename") {
      my @array;
      while (defined (my $line = <FH>)) {
        chomp $line;
        next if $line =~ /^\s*$/;   # ignore blank lines
        my ($i, $n) = split /\s+/, $line;
        if (! (defined $n && $n =~ /^-?[0-9]+$/)) {
          die "oops, bad line in $filename: '$line'";
        }
        if ($n > $max_value) {
          ### stop at bignum value: $line
          last;
        }
        push @array, $n;
      }
      close FH or die;
      return \@array;
    }
    ### no bfile: $!
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
