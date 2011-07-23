#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

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

use 5.004;
use strict;
use warnings;
use POSIX;

# uncomment this to run the ### lines
use Smart::Comments;

{
  require App::MathImage::NumSeq::OEIS::Catalogue;
  my $anum = 'A163544';
  my $info = App::MathImage::NumSeq::OEIS::Catalogue->anum_to_info($anum);
  ### $info

  require App::MathImage::NumSeq::OEIS;
  my $seq = App::MathImage::NumSeq::OEIS->new(anum=>'A163544');
  ### $seq
  exit 0;
}
{
  unshift @INC,'t';
  require MyOEIS;
  my @ret = MyOEIS::read_values('008683');
  ### @ret
  exit 0;
}
{
  require App::MathImage::NumSeq::OEIS::Catalogue::Plugin::ZZ_Files;
  require App::MathImage::NumSeq::OEIS::Catalogue::Plugin::FractionDigits;
  foreach my $info (App::MathImage::NumSeq::OEIS::Catalogue::Plugin::FractionDigits->info_arrayref) {
    ### info: $info->[0]
    my $anum = $info->[0]->{'anum'};
    require App::MathImage::NumSeq::OEIS;
    my $seq = App::MathImage::NumSeq::OEIS->new(anum=>$anum);
  }
  exit 0;
}

{
  require App::MathImage::NumSeq::OEIS::Catalogue;
  my $info = App::MathImage::NumSeq::OEIS::Catalogue->anum_to_info('A000290');
  ### $info
  { my $anum = App::MathImage::NumSeq::OEIS::Catalogue->anum_first;
    ### $anum
  }
  { my $anum = App::MathImage::NumSeq::OEIS::Catalogue->anum_last;
    ### $anum
  }
  {
    my $anum = App::MathImage::NumSeq::OEIS::Catalogue->anum_after('A000032');
    ### $anum
  }
  {
    my $anum = App::MathImage::NumSeq::OEIS::Catalogue->anum_before('A000032');
    ### $anum
  }
  # my @list = App::MathImage::NumSeq::OEIS::Catalogue->anum_list;
  # ### @list

  {
    require App::MathImage::NumSeq::OEIS::Catalogue;
    foreach my $plugin (App::MathImage::NumSeq::OEIS::Catalogue->plugins) {
      ### $plugin
      ### first: $plugin->anum_first
      ### last: $plugin->anum_last
    }
  }

  exit 0;
}


{
  require App::MathImage::NumSeq::OEIS;
  my $seq = App::MathImage::NumSeq::OEIS->new(anum=>'A000032');
  ### $seq
  exit 0;
}
{
  {
    require File::Find;
    my $old = \&File::Find::find;
    no warnings 'redefine';
    *File::Find::find = sub {
      print "File::Find::find\n";
      print "  $_[1]\n";
      goto $old;
    };
  }
  require App::MathImage::NumSeq::OEIS::Catalogue;
  App::MathImage::NumSeq::OEIS::Catalogue->plugins;
  print "\n";
  App::MathImage::NumSeq::OEIS::Catalogue->plugins;
  print "\n";
  App::MathImage::NumSeq::OEIS::Catalogue->plugins;
}

{
  require App::MathImage::NumSeq::OEIS::Catalogue::Plugin::Files;
  my $info = App::MathImage::NumSeq::OEIS::Catalogue::Plugin::Files->anum_to_info(32);
  ### $info
exit 0;
}

