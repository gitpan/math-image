#!/usr/bin/perl -w

# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
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
use Test;
my $test_count;
BEGIN {
  $test_count = 1511;
  plan tests => $test_count;
}

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# only test on 6.6 up since 6.5.5 seen doing dodgy stuff on a 3x3 ellipse,
# coming out with an excess to the right like
#     _____www____________
#     _____wwwww__________
#     _____www____________
#

my $have_image_magick = eval { require Image::Magick; 1 };
if ($have_image_magick) {
  MyTestHelpers::diag ("Image::Magick VERSION ",Image::Magick->VERSION);

  my $im_version = Image::Magick->VERSION;
  if ($im_version =~ /([0-9]*(\.[0-9]*)?)/) {
    my $im_two_version = $1;
    if ($im_two_version < 6.6) {
      MyTestHelpers::diag ("Image::Magick 6.6 not available -- im_version $im_version im_two_version $im_two_version");
      $have_image_magick = 0;
    }
  }
}
if (! $have_image_magick) {
  foreach (1 .. $test_count) {
    skip ('no Image::Magick 6.6', 1, 1);
  }
  exit 0;
}

require App::MathImage::Image::Base::Magick;

# uncomment this to run the ### lines
#use Smart::Comments;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 53;
ok ($App::MathImage::Image::Base::Magick::VERSION,
    $want_version,
    'VERSION variable');
ok (App::MathImage::Image::Base::Magick->VERSION,
    $want_version, 'VERSION class method');

ok (eval { App::MathImage::Image::Base::Magick->VERSION($want_version); 1 },
    1,
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Magick->VERSION($check_version); 1 },
    1,
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# %d filename

my $percent_filename = 'temp%d.png';
MyTestHelpers::diag ("Percentfile ",$percent_filename);
unlink $percent_filename;
ok (! -e $percent_filename, 1, "removed any existing $percent_filename");
END {
  if (defined $percent_filename) {
    MyTestHelpers::diag ("Remove percentfile ",$percent_filename);
    unlink $percent_filename
      or MyTestHelpers::diag ("No remove $percent_filename: ",$!);
  }
}

{
  my $image = App::MathImage::Image::Base::Magick->new (-width => 20,
                                                        -height => 10,
                                                        -file_format => 'png');
  $image->save ($percent_filename);
  ok (-e $percent_filename, 1, "save() to $percent_filename, -e exists");
  ok (-s $percent_filename > 0, 1, "save() to $percent_filename, -s non-empty");
  ok ($image->get('-file'), $percent_filename, 'save() sets -file');
}
{
  # system "ls -l '$percent_filename'";
  my $image = App::MathImage::Image::Base::Magick->new;
  $image->load ($percent_filename);
  ### $image

  # FIXME
  # ok ($image->get('-width'), 20, 'load() -width');
  # ok ($image->get('-height'), 10, 'load() -height');
  # ok ($image->get('-file_format'), 'PNG', 'load() -file_format');
  ok ($image->get('-file'), $percent_filename, 'load() sets -file');
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-file => $percent_filename);
  # FIXME
  # ok ($image->get('-width'), 20, 'new(-file) -width');
  # ok ($image->get('-height'), 10, 'new(-file) -height');
  # ok ($image->get('-file_format'), 'PNG', 'new(-file) -file_format');
  ok ($image->get('-file'), $percent_filename, 'new(-file) sets -file');
}

#------------------------------------------------------------------------------
# new

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  ok (! exists $image->{'-width'}, 1);
  ok (! exists $image->{'-height'}, 1);
  ok ($image->get('-width'), 20);
  ok ($image->get('-height'), 10);

  $image->set (-width => 15);
  ok ($image->get('-width'), 15, 'resize -width');
  ok ($image->get('-height'), 10, 'unchanged -height');
}


#------------------------------------------------------------------------------
# new() clone image, and resize

{
  my $i1 = App::MathImage::Image::Base::Magick->new
    (-width => 11, -height => 22);
  my $i2 = $i1->new;
  $i2->set(-width => 33, -height => 44);

  ok ($i1->get('-width'), 11);
  ok ($i1->get('-height'), 22);
  ok ($i2->get('-width'), 33);
  ok ($i2->get('-height'), 44);
  ok ($i1->get('-imagemagick') != $i2->get('-imagemagick'), 1);
}


#------------------------------------------------------------------------------
# xy()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->xy(3,4, '#AABBCC');
  ok ($image->xy(3,4), '#AABBCC', 'xy() stored');
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 2, -height => 2);
  $image->set(-width => 20, -height => 20);

  MyTestHelpers::dump ($image);
  MyTestHelpers::diag ("xy() in resize store");
  $image->xy (10,10, '#FFFFFF');
  MyTestHelpers::diag ("xy() in resize read");
  ok ($image->xy (10,10), '#FFFFFF', 'xy() in resize');
}


#------------------------------------------------------------------------------
# rectangle()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 4,4, '#AABBCC');
  ok ($image->xy(2,2), '#AABBCC', 'rectangle() unfilled drawn');
  ok ($image->xy(3,3), '#000000', 'rectangle() unfilled centre undrawn');
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 4,4, '#AABBCC', 1);
  ok ($image->xy(2,2), '#AABBCC', 'rectangle() filled drawn');
  ok ($image->xy(3,3), '#AABBCC', 'rectangle() filled centre');

  # $image->get('-imagemagick')->Write ('xpm:-');  
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 2,2, '#AABBCC', 1);
  ok ($image->xy(2,2), '#AABBCC', 'rectangle() 1x1 filled drawn');
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 2,2, '#AABBCC', 0);
  ok ($image->xy(2,2), '#AABBCC', 'rectangle() 1x1 unfilled drawn');
}


#------------------------------------------------------------------------------
# line()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);

  $image->get('-imagemagick')->Set (width => 10, height=> 5);
  $image->get('-imagemagick')->Set (antialias => 0);
  $image->line(0,0, 5,5, '#AABBCC');
  ok ($image->xy(5,0), '#000000', 'line() away');
  ok ($image->xy(2,2), '#AABBCC', 'line() drawn');
}


#------------------------------------------------------------------------------
# load() errors

my $temp_filename = 'tempfile.png';
MyTestHelpers::diag ("Tempfile ",$temp_filename);
unlink $temp_filename;
ok (! -e $temp_filename, 1, "removed any existing $temp_filename");
END {
  if (defined $temp_filename) {
    MyTestHelpers::diag ("Remove tempfile ",$temp_filename);
    unlink $temp_filename
      or MyTestHelpers::diag ("No remove $temp_filename: ",$!);
  }
}

{
  my $eval_ok = 0;
  my $ret = eval {
    my $image = App::MathImage::Image::Base::Magick->new
      (-file => $temp_filename);
    $eval_ok = 1;
    $image
  };
  my $err = $@;
  # MyTestHelpers::diag "new() err is \"",$err,"\"";
  ok ($eval_ok, 0, 'new() error for no file - doesn\'t reach end');
  ok ($ret, undef, 'new() error for no file - return undef');
  ok ($err, '/^Cannot/', 'new() error for no file - error string "Cannot"');
}
{
  my $eval_ok = 0;
  my $image = App::MathImage::Image::Base::Magick->new;
  my $ret = eval {
    $image->load ($temp_filename);
    $eval_ok = 1;
    $image
  };
  my $err = $@;
  # MyTestHelpers::diag "load() err is \"",$err,"\"";
  ok ($eval_ok, 0, 'load() error for no file - doesn\'t reach end');
  ok ($ret, undef, 'load() error for no file - return undef');
  ok ($err, '/^Cannot/', 'load() error for no file - error string "Cannot"');
}

#-----------------------------------------------------------------------------
# save() / load()

{
  my $image = App::MathImage::Image::Base::Magick->new (-width => 20,
                                                        -height => 10,
                                                        -file_format => 'png');
  $image->save ($temp_filename);
  ok (-e $temp_filename, 1, "save() to $temp_filename, -e exists");
  ok (-s $temp_filename > 0, 1, "save() to $temp_filename, -s non-empty");
}
{
  my $image = App::MathImage::Image::Base::Magick->new (-file => $temp_filename);
  # FIXME
  #  ok ($image->get('-width'), 20, 'new(-file) -width');
  #  ok ($image->get('-height'), 10, 'new(-file) -height');
  ok ($image->get('-file_format'), 'PNG', 'new(-file) -file_format');
  ok ($image->get('-file'), $temp_filename, 'new() sets -file');
  ### $image
}
{
  my $image = App::MathImage::Image::Base::Magick->new;
  $image->load ($temp_filename);
  # FIXME
  # ok ($image->get('-width'), 20, 'load() -width');
  # ok ($image->get('-height'), 10, 'load() -height');
  ok ($image->get('-file_format'), 'PNG', 'load() -file_format');
  ok ($image->get('-file'), $temp_filename, 'load() sets -file');
}

#------------------------------------------------------------------------------
# check_image()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width  => 20,
     -height => 10);
  ok ($image->get('-width'), 20);
  ok ($image->get('-height'), 10);
  my $m = $image->get('-imagemagick');
  $m->Set (antialias => 0);

  require MyTestImageBase;
  MyTestImageBase::check_image ($image);
}

exit 0;
