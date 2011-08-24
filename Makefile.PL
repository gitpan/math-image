#!/usr/bin/perl

# Copyright 2010, 2011 Kevin Ryde

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

my %gtk2_optionals = ('Gtk2::Ex::CrossHair'   => 0,
                      # suggest ErrorTextDialog v.7 for popup control
                      'Gtk2::Ex::ErrorTextDialog::Handler' => 7,
                      'Gtk2::Ex::PodViewer'   => 0,
                      'Gtk2::Ex::QuadButton'  => 0,
                     );

my %for_x11 = ('X11::Protocol' => 0,
               # my X11-Protocol-Other
               'X11::Protocol::Other'    => 1,
               'X11::Protocol::WM'       => 2,  # new in v.2
               'X11::Protocol::XSetRoot' => 3,  # new in v.3
               'X11::AtomConstants'      => 2,  # new in v.2
               # my Image-Base-X11-Protocol
               'Image::Base::X11::Protocol::Pixmap' => 0,
               'Image::Base::X11::Protocol::Window' => 0,
              );

my %tk_interface = (# main Perl-Tk of whatever new enough version
                    'Tk::MainWindow' => 0,
                    'Tk::Balloon' => 0,

                    # my Image-Base-Tk
                    'Image::Base::Tk::Photo' => 0,
                   );
my %tk_optionals = (# main Perl-Tk of whatever new enough version
                    'Tk::PNG' => 0,
                    'Tk::JPEG' => 0,
                    # separate Tk-TIFF dist
                    'Tk::TIFF' => 0,
                   );

my %curses_interface = ('Curses::UI' => 0,
                        'Curses::UI::Common' => 0,
                       );

my %maximum_planepath
  = (
     # cf App::MathImage::Generator path_choices() preferences
     'Math::PlanePath::SquareSpiral'   => 5,  # v.5 wider parameter
     'Math::PlanePath::SacksSpiral'    => 1,
     'Math::PlanePath::VogelFloret'    => 12, # v.12 other rotations + fix
     'Math::PlanePath::TheodorusSpiral'      => 6,  # new in v.6
     'Math::PlanePath::ArchimedeanChords'    => 23, # new in v.23
     'Math::PlanePath::MultipleRings'        => 15, # v.15 fix 0,0
     'Math::PlanePath::PixelRings'           => 28, # v.28 fix xy_to_n diagonal
     'Math::PlanePath::Hypot'                => 21, # new in v.21
     'Math::PlanePath::HypotOctant'          => 21, # new in v.21
     'Math::PlanePath::TriangularHypot'      => 30, # new in v.30
     'Math::PlanePath::PythagoreanTree'      => 26, # new in v.26
     'Math::PlanePath::CoprimeColumns'       => 32, # new in v.32

     'Math::PlanePath::DiamondSpiral'        => 1,
     'Math::PlanePath::PentSpiral'           => 4,  # new in v.4
     'Math::PlanePath::PentSpiralSkewed'     => 3,  # new in v.3
     'Math::PlanePath::HexSpiral'            => 9,  # v.9 wider parameter
     'Math::PlanePath::HexSpiralSkewed'      => 9,  # v.9 wider parameter
     'Math::PlanePath::HeptSpiralSkewed'     => 4,  # new in v.4
     'Math::PlanePath::TriangleSpiral'       => 3,  # new in v.3
     'Math::PlanePath::TriangleSpiralSkewed' => 3,  # new in v.3
     'Math::PlanePath::OctagramSpiral'       => 21, # new in v.21
     'Math::PlanePath::KnightSpiral'         => 1,

     'Math::PlanePath::SquareArms'           => 37, # new in v.37
     'Math::PlanePath::DiamondArms'          => 37, # new in v.37
     'Math::PlanePath::HexArms'              => 36, # new in v.36
     'Math::PlanePath::GreekKeySpiral'       => 27, # new in v.27

     'Math::PlanePath::PyramidRows'          => 4,  # v.4 step parameter
     'Math::PlanePath::PyramidSides'         => 1,
     'Math::PlanePath::PyramidSpiral'        => 3,  # new in v.3
     'Math::PlanePath::CellularRule54'       => 40, # new in v.40
     'Math::PlanePath::Corner'               => 1,
     'Math::PlanePath::Diagonals'            => 2,  # v.2 sqrt fix
     'Math::PlanePath::Staircase'            => 16, # new in v.16
     'Math::PlanePath::Rows'                 => 26, # v.26 against width==0
     'Math::PlanePath::Columns'              => 26, # v.26 against height==0

     'Math::PlanePath::PeanoCurve'           => 36, # v.36 radix parameter
     'Math::PlanePath::HilbertCurve'         => 13, # new in v.13
     'Math::PlanePath::ZOrderCurve'          => 34, # v.34 radix parameter
     'Math::PlanePath::ImaginaryBase'        => 41, # new in v.41

     'Math::PlanePath::Flowsnake'            => 38, # new in v.38
     'Math::PlanePath::FlowsnakeCentres'     => 38, # new in v.38
     'Math::PlanePath::GosperIslands'        => 33, # new in v.33
     'Math::PlanePath::GosperSide'           => 35, # new in v.35

     'Math::PlanePath::KochCurve'            => 30, # new in v.30
     'Math::PlanePath::KochPeaks'            => 30, # new in v.30
     'Math::PlanePath::KochSnowflakes'       => 30, # new in v.30
     'Math::PlanePath::QuadricCurve'         => 41, # new in v.41
     'Math::PlanePath::QuadricIslands'       => 41, # new in v.41
     'Math::PlanePath::SierpinskiArrowhead'  => 32, # new in v.32
     'Math::PlanePath::DragonCurve'          => 39, # new in v.39
     'Math::PlanePath::DragonRounded'        => 40, # new in v.40
     'Math::PlanePath::DragonMidpoint'       => 39, # new in v.39
     # 'Math::PlanePath::TwinDragon'           => 41, # new in v.41

     'Math::PlanePath::File'                 => 37, # new in v.37
    );

my %maximum_numseq
  = (
     # cf App::MathImage::Generator values_choices() preferences
     'Math::NumSeq::Squares'    => 1,
     'Math::NumSeq::Pronic'     => 1,
     'Math::NumSeq::Triangular' => 1,
     'Math::NumSeq::Polygonal'  => 1,
     'Math::NumSeq::Cubes'      => 1,
     'Math::NumSeq::Tetrahedral'  => 1,
     'Math::NumSeq::StarNumbers'  => 1,
     'Math::NumSeq::Even'  => 1,
     'Math::NumSeq::Odd'   => 1,

     'Math::NumSeq::Factorials'   => 1,
     'Math::NumSeq::Primorials'   => 1,
     'Math::NumSeq::Fibonacci'    => 1,
     'Math::NumSeq::LucasNumbers' => 1,

     'Math::NumSeq::FractionDigits' => 1,
     'Math::NumSeq::SqrtDigits' => 1,

     'Math::NumSeq::DigitLength'           => 1,
     'Math::NumSeq::DigitLengthCumulative' => 1,
     'Math::NumSeq::RadixWithoutDigit'     => 1,
     'Math::NumSeq::DigitSum' => 2,      # new in v.2
     'Math::NumSeq::DigitProduct' => 2,  # new in v.2

     'Math::NumSeq::Beastly' => 1,
     'Math::NumSeq::Repdigits' => 1,
     'Math::NumSeq::Palindromes' => 1,
     'Math::NumSeq::HarshadNumbers' => 1,

     'Math::NumSeq::CullenNumbers'  => 1,
     'Math::NumSeq::ProthNumbers'   => 1,
     'Math::NumSeq::WoodallNumbers' => 1,

     'Math::NumSeq::CollatzSteps' => 1,

     # in Math-Aronson
     'Math::Aronson'         => 4, # version 4 for lying option
     'Math::NumSeq::Aronson' => 6, # new in v.6
    );

MyMakeMakerExtras::WriteMakefile
  (NAME         => 'math-image',
   ABSTRACT     => 'Draw some mathematical images.',
   VERSION_FROM => 'math-image',
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,
   EXE_FILES    => [ 'math-image' ],
   MIN_PERL_VERSION => '5.008',
   PREREQ_PM =>
   {
    'constant' => 1.02,  # leading underscore in prima bits
    'constant::defer' => 0,
    'Bit::Vector'     => 0,
    'Compress::Zlib'  => 0,
    'Data::Float'  => 0,

    # File::Copy 2.11 of perl 5.10.0 gives warnings on File::Temp file
    # handles by outsmarting itself in some compares plus File::Temp having a
    # bogus numize.  File::Copy 2.14 looks slightly better, though enquiring
    # into the overloadedness of handles really doesn't sound like a good
    # idea.
    'File::Copy'      => '2.14',

    'File::HomeDir' => 0,
    'Geometry::AffineTransform' => '1.3', # version 1.3 for invert()

    'Glib' => '1.220', # for Glib::SOURCE_REMOVE
    'Glib::Object::Subclass' => 0,
    'Glib::Ex::ConnectProperties' => 14, # v.14 for response-sensitive#

    # my Glib-Ex-ObjectBits
    'Glib::Ex::EnumBits'     => 11, # new in v.11
    # 'Glib::Ex::FreezeNotify' => 0,
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
    'Gtk2::Ex::MenuBits'       => 35, # v.35 for mnemonic_escape()
    'Gtk2::Ex::PixbufBits'     => 37, # v.37 fix save_adapt()
    'Gtk2::Ex::Statusbar::MessageUntilKey' => 11,
    'Gtk2::Ex::ToolbarBits'    => 36, # v.36 avoid stray 5.010
    'Gtk2::Ex::ToolItem::CheckButton' => 42,  # new in v.42
    'Gtk2::Ex::ToolItem::OverflowToDialog' => 41,  # v.41 fix overflow-mnemonic
    'Gtk2::Ex::Units'          => 13, # new in v.13
    'Gtk2::Ex::SyncCall'       => 12, # v.12 workaround gtk 2.12 bug
    'Gtk2::Ex::WidgetEvents'   => 21, # new in v.21
    'Test::Weaken::Gtk2'       => 39, # v.39 for ignore_default_root_window()

    # QuadButton / QuadScroll
    'Gtk2::Ex::AdjustmentBits' => 40, # new in v.40
    'Gtk2::Ex::WidgetBits'     => 40, # v.40 for pixel_size_mm()

    # my Gtk2-Ex-ComboBoxBits
    # 'Gtk2::Ex::ComboBoxBits'   => 2, # version 2 fix MoreUtils dependency
    'Gtk2::Ex::ComboBox::Enum' => 5, # for set_active_nick()
    'Gtk2::Ex::ComboBox::Text' => 2,
    'Gtk2::Ex::ComboBox::PixbufType' => 31, # v.31 fix initial for_width
    'Gtk2::Ex::Menu::EnumRadio' => 6, # new in version 6
    'Gtk2::Ex::ToolItem::ComboEnum' => 28, # new in version 28

    'Gtk2::Ex::Dragger' => 2, # v.2 for external adj changes
    'Gtk2::Ex::NumAxis' => 2,
    'Gtk2::Ex::WidgetCursor' => 15, # v.15 for SignalIds fix
    'Gtk2::Ex::Splash' => 1,

    'Image::Base' => '1.16', # version 1.16 for diamond()

    # my Image-Base-Other
    'Image::Base::Multiplex' => 7, # v.7 diamond()
    'Image::Base::Text'      => 0,

    # my Image-Base-Gtk2
    'Image::Base::Gtk2::Gdk::Pixmap' => 2, # v.2 lowering 5.10
    'Image::Base::Gtk2::Gdk::Window' => 2,
    'Image::Base::Gtk2::Gdk::Pixbuf' => 3, # new in v.3

    'List::MoreUtils' => '0.24', # 0.24 for stack growing, maybe
    'Locale::TextDomain' => '1.19',
    'Locale::Messages' => 0,
    'Module::Load' => 0,
    'Module::Pluggable' => 0,
    'Module::Util' => 0,
    'Number::Format' => 0,
    'Scalar::Util' => '1.18', # for pure-perl refaddr() fix
    'Scope::Guard' => 0,
    'Software::License::GPL_3' => '0.001', # gpl3 in 0.001
    'Text::Capitalize' => 0,
    'Term::Size' => 0,

    'Math::Prime::XS' => '0.23', # version 0.23 for fix of 1928099

    'Math::BaseCnv' => 0,
    'Math::Libm' => 0,
    # 'Math::Prime::TiedArray' => 0,

    # my Math-PlanePath, and should work with any set of paths
    'Math::PlanePath' => 40, # v.40 for arms_count()
    'Math::PlanePath::SquareSpiral'   => 1,

    # my Math-NumSeq
    'Math::NumSeq' => 1,
    'Math::NumSeq::Polygonal' => 1,
    # these for sequences in-progress ...
    'Math::NumSeq::Base::Array' => 1,
    'Math::NumSeq::Base::Digits' => 1,
    'Math::NumSeq::Base::IterateIth' => 1,
    'Math::NumSeq::Base::IteratePred' => 1,
    'Math::NumSeq::Base::Sparse' => 1,


    # 'Math::PlanePath' => 37, # for experimental paths _round_nearest() etc
    'Math::PlanePath::SierpinskiArrowhead' => 32,  # Skewed experiment
    'Math::PlanePath::SacksSpiral' => 1, # for CrossSide in progress ...
   },

   META_MERGE =>
   { resources =>
     { homepage => 'http://user42.tuxfamily.org/math-image/index.html',
     },
     recommends =>
     {
      %maximum_planepath,
      %maximum_numseq,
      %gtk2_optionals,
      %for_x11,
      'Math::Symbolic' => '0.605', # 0.605 fixing a simplify
      'Math::Expression::Evaluator' => 0, # maybe any ok
      'Language::Expr' => '0.14',
      'Image::Xpm'     => 0,
     },
     optional_features =>
     {
      for_x11 =>
      { description => 'Things for native X through X11::Protocol.',
        requires => \%for_x11,
      },
      gtk2_optionals =>
      { description => 'Gtk2 things used if available.',
        requires => \%gtk2_optionals,
      },

      tk_interface =>
      { description => 'Tk GUI modules.',
        requires => \%tk_interface,
      },
      tk_optionals =>
      { description => 'Tk things used if available.',
        requires => \%tk_optionals,
      },

      curses_interface =>
      { description => 'Experimental Curses interface.',
        requires => \%curses_interface,
      },

      maximum_planepath =>
      { description => 'Maximum PlanePath modules',
        requires => \%maximum_planepath,
      },
      maximum_numseq =>
      { description => 'Maximum NumSeq number sequence modules',
        requires => \%maximum_numseq,
      },
      maximum_interoperation =>
      { description => 'All the optional things Math-Image can use.',
        requires => {
                     %maximum_planepath,
                     %maximum_numseq,
                     %for_x11,
                     %gtk2_optionals,
                     %tk_interface,
                     %tk_optionals,

                     'Image::Xpm'             => 0,
                     'Image::Base::GD'        => 8, # v.8 ellipse() $fill
                     'Image::Base::Imager'    => 0,
                     'Image::Base::Magick'    => 0,
                     # v.5 ellipse() $fill
                     # v.7 recommended for diamond()
                     'Image::Base::PNGwriter' => 7,
                     'Image::Base::SVG'       => 3, # v.3 diamond()
                     'Image::Base::SVGout'    => 7, # v.7 diamond()

                     'Math::Symbolic' => 0.605, # 0.605 fix a simplify()
                     'Math::Expression::Evaluator' => 0,
                     'Language::Expr' => '0.14',

                     'Prima' => 0,
                     'Image::Base::Prima' => 1,
                    },
      },
      maximum_tests =>
      { description => 'Have "make test" do as much as possible.',
        requires => { 'Test::Weaken'           => 3,
                      'Image::Xpm'             => 0,
                      'Image::Base::GD'        => 4, # bug fixes
                      'Image::Base::PNGwriter' => 2, # bug fixes
                    },
      },
     },
   },
  );
