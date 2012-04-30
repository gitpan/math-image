#!/usr/bin/perl -w

# Copyright 2011, 2012 Kevin Ryde

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
use Wx;

# uncomment this to run the ### lines
use Devel::Comments;

{
  require App::MathImage::Image::Base::Wx::DC;

  my $bitmap = Wx::Bitmap->new (21,10);
  my $dc = Wx::MemoryDC->new;
  $dc->SelectObject($bitmap);
  $dc->IsOk or die;

  my $pen = $dc->GetPen;
  $pen->SetCap(Wx::wxCAP_PROJECTING());
  $dc->SetPen($pen);

  my $image = App::MathImage::Image::Base::Wx::DC->new
    (-dc => $dc,
     # -width => 21, -height => 10,
    );
  my $black = 'black';
  $MyTestImageBase::white = 'white';
  $MyTestImageBase::white = 'white';
  $MyTestImageBase::black = $black;
  $MyTestImageBase::black = $black;
  my ($width, $height) = $image->get('-width','-height');
  ### $width
  ### $height

  $image->xy (-100,-100);
  ### fetch xy(): $image->xy (-100,-100)

  # $image->rectangle (0,0, $width-1,$height-1, $black, 1);
  # $image->line (5,5, 7,7, 'white', 0);
  # 
  # $image->rectangle (0,0, $width-1,$height-1, $black, 1);

  use lib 't';
  require MyTestImageBase;
  MyTestImageBase::dump_image($image);

  my ($size) = $dc->GetSize;
  ### $size
  ### width: $size->GetWidth
  ### height: $size->GetHeight

  exit 0;
}

{
  require Package::Stash;
  my $stash = Package::Stash->new('Wx::Window');
  ### syms: $stash->list_all_symbols('CODE')
  exit 0;
}
{
  my @size = Wx::GetDisplaySize();
  ### @size
  exit 0;
}
{
  my $app = Wx::SimpleApp->new;
  my $info = Wx::AboutDialogInfo->new;

  $app->MainLoop;
  exit 0;
}
