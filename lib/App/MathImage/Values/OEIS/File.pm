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

package App::MathImage::Values::OEIS::File;
use 5.004;
use strict;
use warnings;
use Carp;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::ValuesArray';

use vars '$VERSION';
$VERSION = 43;

use constant name => __('OEIS File');
sub description {
  my ($class_or_self) = @_;
  if (ref $class_or_self && defined $class_or_self->{'description'}) {
    return $class_or_self->{'description'};
  }
  return __('OEIS sequence from file.');
}

# uncomment this to run the ### lines
#use Smart::Comments;

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

  my $anum = $options{'anum'};
  ### $anum
  my $aref = _read_values($anum);
  ### $aref
  my %info = _read_info($anum, $aref);
  $aref ||= delete $info{'array'};

  if (! $aref) {
    croak "B-file or HTML not found for A-number \"",$anum,"\"";
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

sub anum_to_bfile {
  my ($str, $prefix) = @_;
  $prefix ||= 'b';
  $str =~ s/^A//;
  return sprintf '%s%06d.txt', $prefix, $str;
}

sub anum_to_html {
  my ($str, $ext) = @_;
  $ext ||= '.html';
  $str =~ s/^A//;
  return sprintf 'A%06d%s', $str, $ext;
}

sub _read_info {
  my ($anum, $aref) = @_;

  my @ret;
  foreach my $basefile (anum_to_html($anum), anum_to_html($anum,'.htm')) {
    my $filename = File::Spec->catfile (oeis_dir(), $basefile);
    ### $basefile
    ### $filename
    if (open FH, "<$filename") {
      my $contents = do { local $/; <FH> }; # slurp
      close FH or die;

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
  my ($anum) = @_;

  require File::Spec;
  foreach my $basefile (anum_to_bfile($anum,'a'), anum_to_bfile($anum)) {
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
