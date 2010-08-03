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
   PREREQ_PM    => {
                    'constant::defer' => 0,
                    'Bit::Vector' => 0,
                    'Compress::Zlib' => 0,
                    'Glib' => 0,
                    'Glib::Object::Subclass' => 0,
                    'Glib::Ex::ConnectProperties' => 7, # for transforms
                    'Glib::Ex::SourceIds' => 2,  # new in ObjectBits 2
                    'Glib::Ex::SignalIds' => 0,
                    'Gtk2' => '1.200',

                    # my WidgetBits
                    'Gtk2::Ex::ActionTooltips' => 10, # new in v.10
                    'Gtk2::Ex::Statusbar::MessageUntilKey' => 11,
                    'Gtk2::Ex::Units'          => 13, # new in v.13
                    'Test::Weaken::Gtk2'       => 17, # new in v.17

                    'Gtk2::Ex::WidgetCursor' => 0,

                    'Image::Base' => 0,
                    'Image::Base::Multiplex' => 0,
                    'Image::Base::Text' => 0,  # comes with Multiplex
                    'Image::Base::Gtk2::Gdk::Pixmap' => 0,
                    'Image::Base::Gtk2::Gdk::Window' => 0,

                    'Lingua::EN::Numbers' => '1.01', # version 1.01 rewrite
                    # 'Lingua::FR::Numbers' => 0,
                    'Lingua::Any::Numbers' => 0,
                    'List::MoreUtils' => 0,
                    'Locale::TextDomain' => '1.19',
                    'Locale::Messages' => 0,
                    'Module::Load' => 0,
                    'Module::Util' => 0,
                    'Scalar::Util' => '1.18', # for pure-perl refaddr() fix
                    'Scope::Guard' => 0,
                    'Software::License::GPL_3' => 0,
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
                    # these new in v.3
                    'Math::PlanePath::PyramidSpiral'        => 3,
                    'Math::PlanePath::TriangleSpiral'       => 3,
                    'Math::PlanePath::TriangleSpiralSkewed' => 3,
                    'Math::PlanePath::PentSpiralSkewed'     => 3,
                    # these new in v.4
                    'Math::PlanePath::PentSpiral'           => 4,
                    'Math::PlanePath::HeptSpiralSkewed'     => 4,
                    # this new in v.6
                    'Math::PlanePath::TheodorusSpiral'      => 6,
                   },
   MIN_PERL_VERSION => '5.008',

   META_MERGE
   => { resources
        => { homepage => 'http://user42.tuxfamily.org/math-image/index.html',
           },
        recommends
        => { 'Math::Symbolic' => 0,
             'Image::Xpm' => 0,
             'Image::Base::X11::Protocol::Pixmap' => 0,
             'Image::Base::X11::Protocol::Window' => 0,
             'Gtk2::Ex::CrossHair' => 0,
             'Gtk2::Ex::ErrorDialog' => 0,
           },
        optional_features
        => {
            maximum_interoperation
            => { description => 'All the optional things Math-Image can use.',
                 requires => {
                              'Gtk2::Ex::CrossHair' => 0,
                              'Gtk2::Ex::ErrorTextDialog::Handler' => 0,
                              'Image::Xpm'             => 0,
                              'Image::Base::GD'        => 4, # bug fixes
                              'Image::Base::PNGwriter' => 2, # bug fixes
                              'Image::Base::X11::Protocol::Pixmap' => 0,
                              'Image::Base::X11::Protocol::Window' => 0,
                              'Math::Symbolic'         => 0,
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
