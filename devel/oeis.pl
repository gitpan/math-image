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

use Smart::Comments;


{
  require App::MathImage::NumSeq::OeisCatalogue;
  my $info = App::MathImage::NumSeq::OeisCatalogue->num_to_info(32);
  ### $info
  { my $num = App::MathImage::NumSeq::OeisCatalogue->num_first;
    ### $num
  }
  { my $num = App::MathImage::NumSeq::OeisCatalogue->num_last;
    ### $num
  }
  {
    my $num = App::MathImage::NumSeq::OeisCatalogue->num_after(32);
    ### $num
  }
  {
    my $num = App::MathImage::NumSeq::OeisCatalogue->num_before(32);
    ### $num
  }
  # my @list = App::MathImage::NumSeq::OeisCatalogue->num_list;
  # ### @list

  {
    require App::MathImage::NumSeq::OeisCatalogue;
    foreach my $plugin (App::MathImage::NumSeq::OeisCatalogue->plugins) {
      ### $plugin
      ### first: $plugin->num_first
      ### last: $plugin->num_last
    }
  }

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
  require App::MathImage::NumSeq::OeisCatalogue;
  App::MathImage::NumSeq::OeisCatalogue->plugins;
  print "\n";
  App::MathImage::NumSeq::OeisCatalogue->plugins;
  print "\n";
  App::MathImage::NumSeq::OeisCatalogue->plugins;
}
{
  require App::MathImage::NumSeq::Sequence::OEIS;
  my $seq = App::MathImage::NumSeq::Sequence::OEIS->new(oeis_number=>32);
  ### $seq
  exit 0;
}
{
  require App::MathImage::NumSeq::OeisCatalogue::Plugin::Files;
  my $info = App::MathImage::NumSeq::OeisCatalogue::Plugin::Files->num_to_info(32);
  ### $info
exit 0;
}

