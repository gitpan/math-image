#!/usr/bin/perl

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
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
use ExtUtils::MakeMaker;
use lib 'inc';
use MyMakeMakerExtras;

MyMakeMakerExtras::WriteMakefile
  (NAME         => 'math-image',
   ABSTRACT     => 'Draw some mathematical images.',
   VERSION_FROM => 'math-image',
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,
   EXE_FILES    => [ 'math-image' ],
   PREREQ_PM    =>
   {
    'constant::defer' => 0,
    'Bit::Vector' => 0,
    'Compress::Zlib' => 0,

    'Glib' => '1.220', # for Glib::SOURCE_REMOVE
    'Glib::Object::Subclass' => 0,
    'Glib::Ex::ConnectProperties' => 11, # v.11 for widget-allocation

    # my Glib-Ex-ObjectBits
    'Glib::Ex::ObjectBits' => 12, # new in v.12
    'Glib::Ex::SourceIds'  => 2,  # new in v.2
    'Glib::Ex::SignalIds'  => 0,
    # 'Glib::Ex::SignalBits' => 9, # new in v.9
    'Glib::Ex::EnumBits'   => 11, # new in v.11

    'Gtk2' => '1.220',

    # my Gtk2-Ex-WidgetBits
    'Gtk2::Ex::ActionTooltips' => 10, # new in v.10
    'Gtk2::Ex::GdkBits'        => 23, # version 23 window_clear_region()
    'Gtk2::Ex::Statusbar::MessageUntilKey' => 11,
    'Gtk2::Ex::Units'          => 13, # new in v.13
    'Gtk2::Ex::WidgetEvents'   => 21, # new in v.21
    'Test::Weaken::Gtk2'       => 17, # new in v.17

    'Gtk2::Ex::ComboBox::Enum' => 1,
    'Gtk2::Ex::ComboBox::Text' => 1,
    'Gtk2::Ex::NumAxis' => 2,
    'Gtk2::Ex::WidgetCursor' => 0,
    'Image::Base' => 0,

    # my Image-Base-Other
    'Image::Base::Multiplex' => 0,
    'Image::Base::Text'      => 0,

    # my Image-Base-Gtk2
    'Image::Base::Gtk2::Gdk::Pixmap' => 2, # v.2 lowering 5.10
    'Image::Base::Gtk2::Gdk::Window' => 2,
    'Image::Base::Gtk2::Gdk::Pixbuf' => 3, # new in v.3

    'List::MoreUtils' => '0.24', # 0.24 for stack growing, maybe
    'Locale::TextDomain' => '1.19',
    'Locale::Messages' => 0,
    'Module::Load' => 0,
    'Module::Util' => 0,
    'Scalar::Util' => '1.18', # for pure-perl refaddr() fix
    'Scope::Guard' => 0,
    'Software::License::GPL_3' => '0.001', # new in 0.001
    'Text::Capitalize' => 0,
    'Term::Size' => 0,

    # version 0.20_01 for uninitialized array fix
    'Math::Prime::XS' => '0.20_01',

    'Math::Libm' => 0,
    # 'Math::Prime::TiedArray' => 0,
    'Math::TriangularNumbers' => '1.012',

    # my Math-PlanePath
    'Math::PlanePath' => 0,
    'Math::PlanePath::Diagonals'    => 2, # sqrt fix
    'Math::PlanePath::SquareSpiral' => 5, # wider parameter
    'Math::PlanePath::PyramidRows'  => 4, # step parameter
    'Math::PlanePath::PyramidSpiral'        => 3,  # new in v.3
    'Math::PlanePath::TriangleSpiral'       => 3,
    'Math::PlanePath::TriangleSpiralSkewed' => 3,
    'Math::PlanePath::PentSpiralSkewed'     => 3,
    'Math::PlanePath::PentSpiral'           => 4,  # new in v.4
    'Math::PlanePath::HexSpiral'            => 9,  # wider parameter
    'Math::PlanePath::HexSpiralSkewed'      => 9,  # wider parameter
    'Math::PlanePath::HeptSpiralSkewed'     => 4,
    'Math::PlanePath::TheodorusSpiral'      => 6,  # new in v.6
    'Math::PlanePath::MultipleRings'        => 7,  # new in v.7
   },
   MIN_PERL_VERSION => '5.008',

   META_MERGE
   => { resources
        => { homepage => 'http://user42.tuxfamily.org/math-image/index.html',
           },
        recommends
        => { 'Math::Aronson'  => 2,
             'Math::Symbolic' => 0, # probably almost any ok
             'Image::Base' => '1.09',  # for ellipse() fixes
             'Image::Xpm'     => 0,
             'Image::Base::X11::Protocol::Pixmap' => 0,
             'Image::Base::X11::Protocol::Window' => 0,
             'Gtk2::Ex::CrossHair'   => 0,
             'Gtk2::Ex::ErrorDialog' => 7, # suggest v.7 for popup control
             'Gtk2::Ex::PodViewer'   => 0,
           },
        optional_features
        => {
            maximum_interoperation
            => { description => 'All the optional things Math-Image can use.',
                 requires => {
                              'Gtk2::Ex::CrossHair' => 0,
                              # suggest ErrorTextDialog v.7 for popup control
                              'Gtk2::Ex::ErrorTextDialog::Handler' => 7,
                              'Gtk2::Ex::PodViewer'    => 0,
                              'Image::Xpm'             => 0,
                              'Image::Base::GD'        => 4, # bug fixes
                              'Image::Base::PNGwriter' => 2, # bug fixes
                              'Image::Base::X11::Protocol::Pixmap' => 0,
                              'Image::Base::X11::Protocol::Window' => 0,
                              'Math::Aronson'  => 1,
                              'Math::Symbolic' => 0,
                             },
               },
            maximum_tests
            => { description => 'Have "make test" do as much as possible.',
                 requires => { 'Test::Weaken'           => 3,
                               'Image::Xpm'             => 0,
                               'Image::Base::GD'        => 4, # bug fixes
                               'Image::Base::PNGwriter' => 2, # bug fixes
                             },
               },
           },
      },
  );
