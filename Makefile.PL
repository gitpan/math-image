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
    'Bit::Vector'     => 0,
    'Compress::Zlib'  => 0,
    # File::Copy 2.11 of perl 5.10.0 gives warnings on File::Temp file
    # handles by outsmarting itself in some compares.  2.14 looks slightly
    # better, though enquiring into the overloadedness of handles really
    # doesn't sound like a good idea.
    'File::Copy'      => '2.14',

    'Glib' => '1.220', # for Glib::SOURCE_REMOVE
    'Glib::Object::Subclass' => 0,
    'Glib::Ex::ConnectProperties' => 11, # v.11 for widget-allocation

    # my Glib-Ex-ObjectBits
    'Glib::Ex::EnumBits'     => 11, # new in v.11
    'Glib::Ex::FreezeNotify' => 0,
    'Glib::Ex::ObjectBits'   => 12, # new in v.12
    'Glib::Ex::SourceIds'    => 2,  # new in v.2
    'Glib::Ex::SignalBits'   => 9,  # new in v.9
    'Glib::Ex::SignalIds'    => 0,

    'Gtk2' => '1.220',
    'Gtk2::Pango' => 0, # part of Gtk2, used explicitly

    # my Gtk2-Ex-WidgetBits
    'Gtk2::Ex::ActionTooltips' => 10, # new in v.10
    'Gtk2::Ex::ContainerBits'  => 21, # new in v.21
    'Gtk2::Ex::GdkBits'        => 23, # v.23 for window_clear_region()
    'Gtk2::Ex::MenuItem::Subclass' => 29, # new in v.29
    'Gtk2::Ex::Statusbar::MessageUntilKey' => 11,
    'Gtk2::Ex::Units'          => 13, # new in v.13
    'Gtk2::Ex::SyncCall'       => 12, # v.12 workaround gtk 2.12 bug
    'Gtk2::Ex::WidgetEvents'   => 21, # new in v.21
    'Test::Weaken::Gtk2'       => 17, # new in v.17

    # my Gtk2-Ex-ComboBoxBits
    'Gtk2::Ex::ComboBoxBits'   => 2, # version 2 for fixed MoreUtils dependency
    'Gtk2::Ex::ComboBox::Enum' => 5, # for set_active_nick()
    'Gtk2::Ex::ComboBox::Text' => 2,
    'Gtk2::Ex::ComboBox::PixbufType' => 4, # new in version 4
    'Gtk2::Ex::Menu::EnumRadio' => 6, # new in version 6

    'Gtk2::Ex::Dragger' => 2, # v.2 for external adj changes
    'Gtk2::Ex::NumAxis' => 2,
    'Gtk2::Ex::WidgetCursor' => 15, # v.15 for SignalIds fix
    'Image::Base' => '1.09',  # for ellipse() fixes

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
    'Number::Format' => 0,
    'Scalar::Util' => '1.18', # for pure-perl refaddr() fix
    'Scope::Guard' => 0,
    'Software::License::GPL_3' => '0.001', # new in 0.001
    'Text::Capitalize' => 0,
    'Term::Size' => 0,

    'Math::Prime::XS' => '0.22', # version 0.22 for lo==hi

    'Math::BaseCnv' => 0,
    'Math::Libm' => 0,
    # 'Math::Prime::TiedArray' => 0,

    'Math::PlanePath' => 1,
    # subclasses per Generator.pm path_choices()
    'Math::PlanePath::SquareSpiral'   => 5,  # v.5 wider parameter
    'Math::PlanePath::SacksSpiral'    => 1,
    'Math::PlanePath::VogelFloret'    => 12, # v.12 other rotations + fix
    'Math::PlanePath::TheodorusSpiral'      => 6,  # new in v.6
    'Math::PlanePath::MultipleRings'        => 10, # v.10 fix xy_to_n
    'Math::PlanePath::DiamondSpiral'        => 1,
    'Math::PlanePath::PentSpiral'           => 4,  # new in v.4
    'Math::PlanePath::PentSpiralSkewed'     => 3,  # new in v.3
    'Math::PlanePath::HexSpiral'            => 9,  # v.9 wider parameter
    'Math::PlanePath::HexSpiralSkewed'      => 9,  # v.9 wider parameter
    'Math::PlanePath::HeptSpiralSkewed'     => 4,  # new in v.4
    'Math::PlanePath::TriangleSpiral'       => 3,  # new in v.3
    'Math::PlanePath::TriangleSpiralSkewed' => 3,  # new in v.3
    'Math::PlanePath::KnightSpiral'         => 1,
    'Math::PlanePath::PyramidRows'          => 4,  # step parameter
    'Math::PlanePath::PyramidSides'         => 1,
    'Math::PlanePath::PyramidSpiral'        => 3,  # new in v.3
    'Math::PlanePath::Corner'               => 1,
    'Math::PlanePath::Diagonals'            => 2,  # v.2 sqrt fix
    'Math::PlanePath::Rows'                 => 7,  # v.7 rect_to_n_range
    'Math::PlanePath::Columns'              => 7,  # v.7 rect_to_n_range
    'Math::PlanePath::HilbertCurve'         => 13, # new in v.13
    'Math::PlanePath::ZOrderCurve'          => 13, # new in v.13
   },
   MIN_PERL_VERSION => '5.008',

   META_MERGE
   => { resources
        => { homepage => 'http://user42.tuxfamily.org/math-image/index.html',
           },
        recommends
        => { 'Math::Aronson'  => 4, # version 4 for lying option
             'Math::Symbolic' => 0, # probably almost any ok
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
                              'Math::Aronson'  => 4, # version 4 for lying
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
