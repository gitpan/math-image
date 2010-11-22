#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

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

use 5.010;
use strict;
use warnings;

#use Smart::Comments;

# use blib "$ENV{HOME}/perl/prima/Prima-1.28/blib";
use lib "$ENV{HOME}/perl/prima/Prima-1.28/inst/local/lib/perl/5.10.1/";
{
  use Prima;
  use Prima::Const;

  my $d = Prima::Image->create (width => 5, height => 3);
  $d->begin_paint;
  $d->lineWidth(1);

  $d->color (cl::Black);
  $d->bar (0,0, 50,50);

  $d->color (cl::White);
  $d->fill_ellipse (2,1, 5,3);

  $d->end_paint;
  $d-> save('/tmp/foo.gif') or die "Error saving:$@\n";
  system "xzgv -z /tmp/foo.gif";
  exit 0;
}
{
  require Prima;

  printf "white %X\n", cl::White();
  my $coderef = cl->can('White');
  printf "white coderef %s  %X\n", $coderef, &$coderef();

  require App::MathImage::Image::Base::Prima::Drawable;
  my $d = Prima::Image->create (width => 100,
                                height => 100,
                                type => im::bpp8(),
                                # type => im::RGB(),
                               );
  # $d-> palette([0,255,0],[255,255,255], [0xFF,0x00,0xFF], [0x00,0xFF,0x00]);
  # $d-> palette([0,255,0, 255,255,255, 0xFF,0x00,0xFF, 0x00,0xFF,0x00]);
  # $d-> palette(0x000000, 0xFF00FF, 0xFFFFFF, 0x00FF00);
  ### palette: $d-> palette

  ### bpp: $d->get_bpp

  my $image = App::MathImage::Image::Base::Prima::Drawable->new
    (-drawable => $d);
  print "width ", $image->get('-width'), "\n";
  $image->set('-width',20);
  $image->set('-height',10);
  print "width ", $image->get('-width'), "\n";

  $d->begin_paint;
  $d->color (cl::Black());
  $d->bar (0,0, 20,10);
  # $image->ellipse(1,1, 18,8, 'white');
  $image->ellipse(1,1, 5,3, 'white', 1);
  # $image->xy(6,4, 'white');
  # $image->rectangle(0,0,10,10, 'green');

  # $image->xy(0,0, '#00FF00');
  # $image->xy(1,1, '#FFFF0000FFFF');
  # print "xy ", $image->xy(0,0), "\n";
  # say $d->pixel(0,0);

  $d->end_paint;
  $d-> save('/tmp/foo.gif') or die "Error saving:$@\n";
  system "xzgv -z /tmp/foo.gif";
  exit 0;
}

{
  use Prima;
  use Prima::Const;

  my $d = Prima::Image->new;
  $d = Prima::Image->load('/usr/share/emacs/23.2/etc/images/icons/hicolor/16x16/apps/emacs.png',
                          loadExtras => 1);
  ### width: $d->width
  ### heightwidth: $d->height
  ### extras: $d->{'extras'}
  my $codecs = $d->codecs;
  ### codecs: ref($codecs)
  ### codecs: map {$_->{'fileShortType'}} @{$d->codecs}

  $d = Prima::Image->new (width => 1, height => 1);
  $d->save (\*STDOUT)
    or die $@;
  exit 0;
}


{
  # available cL:: colour names
  require Prima;
  my @array;
  foreach my $name (keys %cl::) {
    if ($name eq 'AUTOLOAD' || $name eq 'constant') {
      print "$name\n";
      next;
    }
    my $var = "cl::$name";
    my $value = do { no strict 'refs'; &$var(); };
    push @array, [$name, $value];
  }
  foreach my $elem (sort {$a->[1] <=> $b->[1]} @array) {
    printf "%8s %s\n", sprintf('%06X',$elem->[1]), $elem->[0];
  }
  exit 0;
}

{
  #   require Prima;
  #   require Prima::Const;
  Prima->import('Application');
  use Prima 'Application';

  #  Prima::MainWindow->new;

  #   use Prima::StdDlg;
  #   use Prima::FileDialog;
  #   my $dialog = Prima::FileDialog->create;
  #   $dialog->execute;

  require App::MathImage::Prima::About;
  my $about = App::MathImage::Prima::About->popup;
#  $about->execute;

  Prima->run;
  exit 0;
}

