#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


use 5.008;
use strict;
use warnings;
use Gtk2 '-init';
use Glib::Ex::ConnectProperties;
use App::MathImage::Gtk2::Ex::QuadScroll;

use FindBin;
my $progname = $FindBin::Script;

# uncomment this to run the ### lines
use Smart::Comments;

my $toplevel = Gtk2::Window->new('toplevel');
$toplevel->signal_connect (destroy => sub { Gtk2->main_quit });

my $vbox = Gtk2::VBox->new;
$toplevel->add ($vbox);

my $vadj = Gtk2::Adjustment->new (0,  # initial
                                  -100,  # min
                                  100,  # max
                                  1,10,    # step,page increment
                                  20);      # page_size
my $hadj = Gtk2::Adjustment->new (0,  # initial
                                  -100,  # min
                                  100,  # max
                                  1,10,    # step,page increment
                                  20);      # page_size

my $qb = App::MathImage::Gtk2::Ex::QuadScroll->new
  (hadjustment => $hadj,
   vadjustment => $vadj,
   vinverted   => 1);
$qb->signal_connect_after (change_value => sub {
                             print "$progname: change-value @_\n";
                             if (my $hadj = $qb->{'hadjustment'}) {
                               print "  hadj ",$hadj->value,"\n";
                             }
                             if (my $vadj = $qb->{'vadjustment'}) {
                               print "  vadj ",$vadj->value,"\n";
                             }
                           });
$vbox->add ($qb);
$qb->set_size_request (200, 200);

{
  my $button = Gtk2::CheckButton->new_with_label ('Sensitive');
  Glib::Ex::ConnectProperties->new
      ([$qb, 'sensitive'],
       [$button, 'active']);
  $vbox->pack_start ($button, 0, 0, 0);
}

$toplevel->show_all;

### normal: $qb->style->fg('normal')->to_string
### prelight: $qb->style->fg('prelight')->to_string
### active: $qb->style->fg('active')->to_string
### selected: $qb->style->fg('selected')->to_string
### insensitive: $qb->style->fg('insensitive')->to_string

### normal: $qb->style->bg('normal')->to_string
### prelight: $qb->style->bg('prelight')->to_string
### active: $qb->style->bg('active')->to_string
### selected: $qb->style->bg('selected')->to_string
### insensitive: $qb->style->bg('insensitive')->to_string

### inner-border: $qb->{'up'}->style_get_property('inner-border')
### default-border: $qb->{'up'}->style_get_property('default-border')
### image-spacing: $qb->{'up'}->style_get_property('image-spacing')
### focus-line-width: $qb->{'up'}->style_get_property('focus-line-width')

Gtk2->main;
exit 0;
