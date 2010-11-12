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


package App::MathImage::Gtk2::Main;
use 5.008;
use strict;
use warnings;
use Carp;
use List::Util qw(min max);
use POSIX ();
use Module::Util;
use Glib::Ex::ConnectProperties 8;  # v.7 for transforms, v.8 for write_only
use Gtk2 1.220;
use Gtk2::Ex::ActionTooltips;
use Gtk2::Ex::NumAxis 2;
use Number::Format;
use Locale::TextDomain 1.19 ('App-MathImage');
use Locale::Messages 'dgettext';

use Glib::Ex::EnumBits;
use Glib::Ex::ObjectBits 'set_property_maybe';
use Gtk2::Ex::ComboBox::Text 2; # version 2 for fixed MoreUtils dependency
use Gtk2::Ex::ComboBox::Enum 2; # version 2 for fixed MoreUtils dependency

use App::MathImage::Gtk2::Drawing;
use App::MathImage::Gtk2::Drawing::Values;
use App::MathImage::Gtk2::Ex::ToolItem::Entry;
use App::MathImage::Gtk2::Ex::ToolItem::EnumCombo;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 30;

use Glib::Object::Subclass
  'Gtk2::Window',
  signals => { window_state_event => \&_do_window_state_event,
               destroy => \&_do_destroy,
             },
  properties => [ Glib::ParamSpec->boolean
                  ('fullscreen',
                   'fullscreen',
                   'Blurb.',
                   0,           # default
                   Glib::G_PARAM_READWRITE),
                ];

my %_values_to_mnemonic =
  (Primes        => __('_Primes'),
   TwinPrimes    => __('_Twin Primes'),
   TwinPrimes1   => __('Twin Primes _1'),
   TwinPrimes2   => __('Twin Primes _2'),
   Squares       => __('S_quares'),
   Pronic        => __('Pro_nic'),
   Triangular    => __('Trian_gular'),
   Cubes         => __('_Cubes'),
   Tetrahedral   => __('_Tetrahedral'),
   Perrin        => __('Perr_in'),
   Padovan       => __('Pado_van'),
   Fibonacci     => __('_Fibonacci'),
   FractionBits  => __('F_raction Bits'),
   Polygonal     => __('Pol_ygonal Numbers'),
   PiBits        => __('_Pi Bits'),
   Ln2Bits       => __x('_Log Natural {logarg} Bits', logarg => 2),
   Ln3Bits       => __x('_Log Natural {logarg} Bits', logarg => 3),
   Ln10Bits      => __x('_Log Natural {logarg} Bits', logarg => 10),
   Odd           => __('_Odd Integers'),
   Even          => __('_Even Integers'),
   All           => __('_All Integers'),
  );
sub _values_to_mnemonic {
  my ($str) = @_;
  return ($_values_to_mnemonic{$str}
          || Glib::Ex::EnumBits->to_display_default($str));
}

my %_path_to_mnemonic =
  (SquareSpiral    => __('_Square Spiral'),
   SacksSpiral     => __('_Sacks Spiral'),
   VogelFloret     => __('_Vogel Floret'),
   DiamondSpiral   => __('_Diamond Spiral'),
   PyramidRows     => __('_Pyramid Rows'),
   PyramidSides    => __('_Pyramid Sides'),
   HexSpiral       => __('_Hex Spiral'),
   HexSpiralSkewed => __('_Hex Spiral Skewed'),
   KnightSpiral    => __('_Knight Spiral'),
   Corner          => __('_Corner'),
   Diagonals       => __('_Diagonals'),
   Rows            => __('_Rows'),
   Columns         => __('_Columns'),
  );
sub _path_to_mnemonic {
  my ($str) = @_;
  return ($_path_to_mnemonic{$str}
          || Glib::Ex::EnumBits::to_display_default($str));
}

sub INIT_INSTANCE {
  my ($self) = @_;
  
  my $vbox = $self->{'vbox'} = Gtk2::VBox->new (0, 0);
  $vbox->show;
  $self->add ($vbox);
  
  my $draw = $self->{'draw'} = App::MathImage::Gtk2::Drawing->new;
  
  my $actiongroup = $self->{'actiongroup'} = Gtk2::ActionGroup->new ('main');
  Gtk2::Ex::ActionTooltips::group_tooltips_to_menuitems ($actiongroup);
  
  $actiongroup->add_actions
    ([
      { name  => 'FileMenu',
        label => dgettext('gtk20-properties','_File'),
      },
      { name     => 'SaveAs',
        stock_id => 'gtk-save-as',
        tooltip  => __('Save the image to a file.'),
        callback => sub {
          my ($action, $self) = @_;
          $self->popup_save_as;
        },
      },
      { name     => 'SetRoot',
        label    => __('Set _Root Window'),
        callback => \&_do_action_setroot,
        tooltip  => __('Set the current image as the root window background.'),
      },
      { name     => 'Print',
        stock_id => 'gtk-print',
        tooltip  => __('Print image to a printer.  Currently this merely draws at the screen resolution so might not scale well on a printer with limited resolution.'),
        callback => sub {
          my ($action, $self) = @_;
          $self->print_image;
        },
      },
      { name        => 'Quit',
        stock_id    => 'gtk-quit',
        accelerator => __p('Main-accelerator-key','<Control>Q'),
        callback    => sub {
          my ($action, $self) = @_;
          $self->destroy;
        },
      },
      
      { name  => 'ViewMenu',
        label => dgettext('gtk20-properties','_View'),
      },
      { name  => 'PathMenu',
        label => dgettext('gtk20-properties','_Path'),
      },
      { name  => 'ValuesMenu',
        label => dgettext('gtk20-properties','_Values'),
      },
      { name     => 'Centre',
        label    => __('_Centre'),
        tooltip  => __('Scroll to centre the origin 0,0 on screen (or at the left or bottom if no negatives in the path).'),
        callback => sub {
          my ($action, $self) = @_;
          $self->{'draw'}->centre;
        },
      },
      
      { name  => 'ToolsMenu',
        label => dgettext('gtk20-properties','_Tools'),
      },
      { name  => 'HelpMenu',
        label => dgettext('gtk20-properties','_Help'),
      },
      { name     => 'About',
        stock_id => 'gtk-about',
        callback => sub {
          my ($action, $self) = @_;
          $self->popup_about;
        },
      },
      (defined (Module::Util::find_installed('Gtk2::Ex::PodViewer'))
       ? { name     => 'PodDialog',
           label    => __('_POD Documentation'),
           tooltip  => __('Display the Math-Image program POD documentation (using Gtk2::Ex::PodViewer).'),
           callback => \&_do_action_pod_dialog,
         }
       : ()),
      
      { name     => 'Random',
        label    => __('Random'),
        callback => \&_do_action_random,
        tooltip  => __('Choose a random path, values, scale, etc.
Click repeatedly to see interesting things.'),
      },
     ],
     $self);
  
  {
    my $action = Gtk2::ToggleAction->new (name => 'Fullscreen',
                                          label => __('_Fullscreen'),
                                          tooltip => __('Toggle between full screen and normal window.'));
    $actiongroup->add_action ($action);
    # Control-F clashes with Emacs style keybindings in the spin and
    # expression entry boxes, you get fullscreen toggle instead of
    # forward-character.
    #     $actiongroup->add_action_with_accel
    #       ($action, __p('Main-accelerator-key','<Control>F'));
    Glib::Ex::ConnectProperties->new ([$self,  'fullscreen'],
                                      [$action,'active']);
  }
  {
    my $action = Gtk2::ToggleAction->new (name => 'DrawProgressive',
                                          label => __('_Draw Progressively'),
                                          tooltip => __('Whether to draw progressively on the screen, or show the final image when ready.'));
    $actiongroup->add_action ($action);
    Glib::Ex::ConnectProperties->new ([$draw,  'draw-progressive'],
                                      [$action,'active']);
  }
  {
    my $action = Gtk2::ToggleAction->new (name => 'Axes',
                                          label => __('A_xes'),
                                          tooltip => __('Whether to show axes beside the image.'));
    $actiongroup->add_action ($action);
  }
  $actiongroup->add_toggle_actions
    ([ { name    => 'Toolbar',
         label   => __('_Toolbar'),
         tooltip => __('Whether to show the toolbar.')},
       
       { name    => 'AronsonConjunctions',
         label   => __('_Conjunctions'),
         tooltip => __('Whether to include conjunctions "and" or "et" in the words of the sequence.'),
       },
       
       { name    => 'AronsonLying',
         label   => __('Lying'),
         tooltip => __('Whether to show the "lying" version of the sequence, being positions which are not "T" (or whatever requested letter).'),
       },
     ]);
  {
    my $action = $actiongroup->get_action ('AronsonConjunctions');
    $action->set (draw_as_radio => 1);
    Glib::Ex::ConnectProperties->new ([$draw,'aronson-conjunctions'],
                                      [$action,'active']);
  }
  {
    my $action = $actiongroup->get_action ('AronsonLying');
    Glib::Ex::ConnectProperties->new ([$draw,'aronson-lying'],
                                      [$action,'active']);
  }
  
  if (Module::Util::find_installed('Gtk2::Ex::CrossHair')) {
    $actiongroup->add_toggle_actions
      # name, stock id, label, accel, tooltip, subr, is_active
      ([{ name        => 'Cross',
          label       =>  __('_Cross'),
          # "C" as an accelerator steals that key from the Gtk2::Entry of an
          # expression.  Is that supposed to happen?
          #   accelerator => __p('Main-accelerator-key','C'),
          callback    => \&_do_action_crosshair,
          is_active   => 0,
          tooltip     => __('Display a crosshair of horizontal and vertical lines following the mouse.'),
        },
       ],
       $self);
  }
  
  {
    my $n = 0;
    my $group;
    my %hash;
    foreach my $values (App::MathImage::Generator->values_choices) {
      my $action = Gtk2::RadioAction->new (name  => "Values-$values",
                                           label => _values_to_mnemonic($values),
                                           value => $n);
      $action->set_group ($group);
      $group ||= $action;
      $actiongroup->add_action ($action);
      $hash{$values} = $n;
      $hash{$n++} = $values;
    }
    Glib::Ex::ConnectProperties->new
        ([$draw,  'values'],
         [$group, 'current-value', hash_in => \%hash, hash_out => \%hash ]);
  }
  {
    my $n = 0;
    my $group;
    my %hash;
    foreach my $path (App::MathImage::Generator->path_choices) {
      my $action = Gtk2::RadioAction->new (name  => "Path-$path",
                                           label => _values_to_mnemonic($path),
                                           value => $n);
      $action->set_group ($group);
      $group ||= $action;
      $actiongroup->add_action ($action);
      $hash{$path} = $n;
      $hash{$n++} = $path;
    }
    Glib::Ex::ConnectProperties->new
        ([$draw,  'path'],
         [$group, 'current-value', hash_in => \%hash, hash_out => \%hash]);
  }
  
  my $ui = $self->{'ui'} = Gtk2::UIManager->new;
  $ui->insert_action_group ($actiongroup, 0);
  $self->add_accel_group ($ui->get_accel_group);
  my $ui_str = <<'HERE';
<ui>
  <menubar name='MenuBar'>
    <menu action='FileMenu'>
      <menuitem action='SetRoot'/>
      <menuitem action='SaveAs'/>
      <menuitem action='Print'/>
      <menuitem action='Quit'/>
    </menu>
    <menu action='ViewMenu'>
      <menu action='ValuesMenu'>
HERE
  foreach my $values (App::MathImage::Generator->values_choices) {
    $ui_str .= "      <menuitem action='Values-$values'/>\n";
  }
  $ui_str .= <<'HERE';
      </menu>
      <menu action='PathMenu'>
HERE
  foreach my $path (App::MathImage::Generator->path_choices) {
    $ui_str .= "      <menuitem action='Path-$path'/>\n";
  }
  $ui_str .= <<'HERE';
      </menu>
    <menuitem action='Centre'/>
    </menu>
    <menu action='ToolsMenu'>
HERE
  if ($actiongroup->get_action('Cross')) {
    $ui_str .= "<menuitem action='Cross'/>\n";
  }
  $ui_str .= <<'HERE';
      <menuitem action='Fullscreen'/>
      <menuitem action='DrawProgressive'/>
      <menuitem action='Toolbar'/>
      <menuitem action='Axes'/>
    </menu>
    <menu action='HelpMenu'>
      <menuitem action='About'/>
HERE
  if ($actiongroup->get_action('PodDialog')) {
    $ui_str .= "<menuitem action='PodDialog'/>\n";
  }
  $ui_str .= <<'HERE';
    </menu>
  </menubar>
  <toolbar  name='ToolBar'>
    <toolitem action='Random'/>
    <toolitem action='AronsonConjunctions'/>
    <toolitem action='AronsonLying'/>
    <separator/>
  </toolbar>
</ui>
HERE
  $ui->add_ui_from_string ($ui_str);
  
  my $menubar = $self->menubar;
  $menubar->show;
  $vbox->pack_start ($menubar, 0,0,0);
  
  my $toolbar = $self->toolbar;
  $toolbar->show;
  $vbox->pack_start ($toolbar, 0,0,0);
  
  my $table = $self->{'table'} = Gtk2::Table->new (2, 2);
  $vbox->pack_start ($table, 1,1,0);
  
  my $vbox2 = $self->{'vbox2'} = Gtk2::VBox->new;
  $table->attach ($vbox2, 0,1, 0,1, ['expand','fill'],['expand','fill'],0,0);
  
  $draw->add_events ('pointer-motion-mask');
  $draw->signal_connect (motion_notify_event => \&_do_motion_notify);
  $table->attach ($draw, 0,1, 0,1, ['expand','fill'],['expand','fill'],0,0);
  
  {
    my $hadj = $draw->get('hadjustment');
    my $haxis = Gtk2::Ex::NumAxis->new (adjustment => $hadj,
                                        orientation => 'horizontal');
    $haxis->signal_connect (button_press_event => \&_do_axis_button_press);
    $haxis->add_events (['button-press-mask',
                         'button-release-mask',
                         'button-motion-mask']);
    $table->attach ($haxis, 0,1, 1,2, ['expand','fill'],[],0,0);
    
    my $vadj = $draw->get('vadjustment');
    my $vaxis = Gtk2::Ex::NumAxis->new (adjustment => $vadj,
                                        inverted => 1);
    $vaxis->add_events (['button-press-mask',
                         'button-release-mask',
                         'button-motion-mask']);
    $vaxis->signal_connect (button_press_event => \&_do_axis_button_press);
    $table->attach ($vaxis, 1,2, 0,1, [],['expand','fill'],0,0);
    
    my $action = $actiongroup->get_action ('Axes');
    Glib::Ex::ConnectProperties->new ([$haxis,'visible'],
                                      [$vaxis,'visible'],
                                      [$action,'active']);
    
    my $aframe = Gtk2::AspectFrame->new ('', .5, .5, 1, 0);
    $aframe->set (label => undef,
                  shadow_type => 'none');
    $table->attach ($aframe, 1,2, 1,2,
                    ['fill'],['fill'],0,0);
    my $atable = Gtk2::Table->new (3, 3);
    foreach my $data (['up',1,2, 0,1],
                      ['down',1,2, 2,3],
                      ['left', 0,1, 1,2],
                      ['right', 2,3, 1,2],
                     ) {
      my $button = Gtk2::EventBox->new;
      $button->add_events (['button-press-mask']);
      my $arrow = Gtk2::Arrow->new ($data->[0], 'in');
      $arrow->set_name ('Math_Image_scroll_arrow');
      $button->set_size_request (3,3); # minimum size
      $button->add ($arrow);
      $atable->attach ($button, @{$data}[1,2,3,4],
                       ['fill','expand'],['fill','expand'],0,0);
      # $button->signal_connect (clicked => \&_do_arrow_button_clicked);
      $button->signal_connect (button_press_event => \&_do_arrow_button_clicked);
    }
    $aframe->add ($atable);
    
    Gtk2::Rc->parse_string (<<'HERE');
style "Math_Image_style" {
  GtkArrow::arrow-scaling = 1
}
widget "*.Math_Image_scroll_arrow" style:application "Math_Image_style"
HERE
    #   GtkButton::focus-padding = 0
    #   GtkButton::interior-focus = 0
    #   GtkButton::focus-line-width = 0
    #   GtkButton::image-spacing = 0
    # class "GtkButton" style:application "Math_Image_style"
  }
  $table->show_all;
  
  {
    my $statusbar = $self->{'statusbar'} = Gtk2::Statusbar->new;
    $statusbar->show;
    $vbox->pack_start ($statusbar, 0,0,0);
  }
  {
    my $action = $actiongroup->get_action ('Toolbar');
    Glib::Ex::ConnectProperties->new ([$toolbar,'visible'],
                                      [$action,'active']);
  }
  
  my $toolpos = -999;
  my $path_combobox;
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
      (enum_type => 'App::MathImage::Gtk2::Drawing::Path');
    $toolitem->{'name'} = __('Path');
    set_property_maybe
      ($toolitem, # tooltip-text new in 2.12
       tooltip_text  => __('The path for where to place values in the plane.'));
    $toolitem->show;
    $toolbar->insert ($toolitem, $toolpos++);
    
    $path_combobox = $self->{'path_combobox'} = $toolitem->get_child;
    set_property_maybe ($path_combobox, # tearoff-title new in 2.10
                        tearoff_title => $toolitem->{'name'});
    
    Glib::Ex::ConnectProperties->new ([$draw,'path'],
                                      [$toolitem,'active-nick']);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Wider'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('Wider path.'));
    $toolbar->insert ($toolitem, $toolpos++);
    
    my $pspec = $draw->find_property ('path-wider');
    my $adj = Gtk2::Adjustment->new ($pspec->get_default_value,  # initial
                                     $pspec->get_minimum,  # min
                                     $pspec->get_maximum,  # max
                                     1,10,    # step,page increment
                                     0);      # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'path-wider'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->show;
    $toolitem->set (entry => $spin);
    
    Glib::Ex::ConnectProperties->new
        ([ $path_combobox, 'active-nick' ],
         [ $toolitem, 'visible',
           write_only => 1,
           hash_in    => \%App::MathImage::Generator::pathname_has_wider ]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Pyramid Step'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('Step width for the pyramid rows, half going to each side.'));
    $toolbar->insert ($toolitem, $toolpos++);
    
    my $pspec = $draw->find_property ('pyramid-step');
    my $adj = Gtk2::Adjustment->new ($pspec->get_default_value,  # initial
                                     $pspec->get_minimum,  # min
                                     $pspec->get_maximum,  # max
                                     1,1,     # step,page increment
                                     0);      # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'pyramid-step'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->show;
    $toolitem->set (entry => $spin);
    
    Glib::Ex::ConnectProperties->new ([$path_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'PyramidRows' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Rings Step'));
    # set_property_maybe ($toolitem,
    #                     tooltip_text => __('Multiple ...'));
    $toolbar->insert ($toolitem, $toolpos++);
    
    my $pspec = $draw->find_property ('rings-step');
    my $adj = Gtk2::Adjustment->new ($pspec->get_default_value,  # initial
                                     $pspec->get_minimum,  # min
                                     $pspec->get_maximum,  # max
                                     1,10,     # step,page increment
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'rings-step'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->show;
    $toolitem->set (entry => $spin);

    Glib::Ex::ConnectProperties->new ([$path_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'MultipleRings' => 1 }]);
  }
  my $rotation_type_combobox;
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
      (enum_type => 'App::MathImage::Gtk2::Drawing::RotationType');
    $toolitem->{'name'} = __('Rotation Type');
    # set_property_maybe ($toolitem,
    #                     tooltip_text  => __(''));
    $toolitem->show;
    $toolbar->insert ($toolitem, $toolpos++);
    
    $rotation_type_combobox = $toolitem->get_child;
    set_property_maybe ($rotation_type_combobox, # tearoff-title new in 2.10
                        tearoff_title => $toolitem->{'name'});
    
    Glib::Ex::ConnectProperties->new
        ([$draw,'path-rotation-type'],
         [$rotation_type_combobox,'active-nick']);
    Glib::Ex::ConnectProperties->new ([$path_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'VogelFloret' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Rotation Factor'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('Rotation factor.  If you have Math::Symbolic then this  can be an expression like pi+2*e-phi (constants phi,e,gam,pi), otherwise it should be a plain number.'));
    $toolbar->insert ($toolitem, $toolpos++);
    
    my $entry = $toolitem->get('entry');
    $entry->set_width_chars (10);
    $entry->show;
    $entry->set_text ('-phi');
    
    $entry->signal_connect
      (activate => sub {
         my $expression = $entry->get_text;
         if (eval { require Math::Symbolic;
                    require Math::Symbolic::Constant;
                  }) {
           my $tree = Math::Symbolic->parse_from_string($expression);
           if (! defined $tree) {
             croak "Cannot parse expression: $expression";
           }
           # ENHANCE-ME: contfrac(2,2,2,2...) func
           $tree->implement (phi => Math::Symbolic::Constant->new((1 + sqrt(5)) / 2),
                             e => Math::Symbolic::Constant->euler,
                             pi => Math::Symbolic::Constant->pi,
                             gam => Math::Symbolic::Constant->new(0.5772156649015328606065120),
                            );
           my @vars = $tree->signature;
           if (@vars) {
             croak "Not a constant expression: $expression";
           }
           $expression = $tree->value;
         }
         $draw->set ('path-rotation-factor', $expression);
       });
    # Glib::Ex::ConnectProperties->new
    #     ([$draw,'path-rotation-factor'],
    #      [$entry,'text', read_signal => 'activate']);
    
    my $update_sensitive = sub {
      $toolitem->set
        (visible => 
         ($path_combobox->get('active-nick') eq 'VogelFloret'
          && $rotation_type_combobox->get('active-nick') eq 'custom'));
    };
    $path_combobox->signal_connect ('notify::active-nick' => $update_sensitive);
    $rotation_type_combobox->signal_connect ('notify::active-nick' => $update_sensitive);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Radius Factor'));
    set_property_maybe ($toolitem,  # tooltip-text new in 2.12
                        tooltip_text => __('Radius factor, spreading points out to make them non-overlapping.  0 means the default factor.'));
    $toolbar->insert ($toolitem, $toolpos++);
    
    my $adj = Gtk2::Adjustment->new (0,        # initial
                                     0, 999,   # min,max
                                     1,1,      # step,page increment
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$adj,'value'],
                                      [$adj,'step-increment',
                                       write_only => 1,
                                       func_in => sub { $_[0] ? 0.1 : 1.0 } ]);
    Glib::Ex::ConnectProperties->new ([$draw,'path-radius-factor'],
                                      [$adj,'value']);
    
    my $spin = Gtk2::SpinButton->new ($adj, 2, 1);
    $toolitem->set (entry => $spin);
    $spin->show;
    
    Glib::Ex::ConnectProperties->new ([$path_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'VogelFloret' => 1 }]);
  }
  
  {
    my $separator = Gtk2::SeparatorToolItem->new;
    $separator->show;
    $toolbar->insert ($separator, $toolpos++);
  }
  my $values_combobox;
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
      (enum_type => 'App::MathImage::Gtk2::Drawing::Values');
    $toolitem->{'name'} = __('Values');
    $toolitem->show;
    $toolbar->insert ($toolitem, $toolpos++);

    $values_combobox = $self->{'values_combobox'} = $toolitem->get_child;
    set_property_maybe ($values_combobox, # tearoff-title new in 2.10
                        tearoff_title => $toolitem->{'name'});
    
    $values_combobox->signal_connect
      ('notify::active-nick' => sub {
         my ($values_combobox) = @_;
         if (my $toolitem = $values_combobox->get_parent) {
           my $values = $values_combobox->get('active-nick');
           my $tooltip = __('The values to display.');
           my $enum_type = $values_combobox->get('enum_type');
           if (my $desc = Glib::Ex::EnumBits::to_description
               ($enum_type, $values)) {
             my $name = Glib::Ex::EnumBits::to_display
               ($enum_type, $values);
             $tooltip .= "\n\n"
               . __x('Current setting: {name}', name => $name)
                 . "\n"
                   . $desc;
           }
           ### $tooltip
           set_property_maybe ($toolitem, tooltip_text => $tooltip);
         }
       });
    
    Glib::Ex::ConnectProperties->new ([$draw,'values'],
                                      [$values_combobox,'active-nick']);
    ### values combobox initial: $values_combobox->get('active-nick')
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Radix'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('Radix, ie. base, for the values calculation.  Default is decimal, base 10, or perhaps binary.'));
    $toolbar->insert ($toolitem, $toolpos++);

    my $pspec = $draw->find_property ('values-radix');
    my $adj = Gtk2::Adjustment->new ($pspec->get_default_value,  # initial
                                     $pspec->get_minimum,  # min
                                     $pspec->get_maximum,  # max
                                     1,10,     # step,page increment
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'values-radix'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->show;
    $toolitem->set (entry => $spin);

    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'Emirps' => 1,
                                                    'Repdigits' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Fraction'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('The fraction to show, for example 5/29.  Press Return when ready to display the expression.'));
    $toolbar->insert ($toolitem, $toolpos++);
    $toolitem->show_all;
    
    my $entry = $toolitem->get('entry');
    $entry->set_width_chars (12);
    Glib::Ex::ConnectProperties->new
        ([$draw,'fraction'],
         [$entry,'text', read_signal => 'activate']);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'FractionBits' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Expression'));
    set_property_maybe ($toolitem,  # tooltip-text new in 2.12
                        tooltip_text => __('A mathematical expression giving values to display, for example x^2+x+41.  Only one variable is allowed, see Math::Symbolic for possible operators and function.  Press Return when ready to display the expression.'));
    $toolbar->insert ($toolitem, $toolpos++);

    my $entry = $toolitem->get('entry');
    $entry->set_width_chars (30);
    $toolitem->show_all;

    Glib::Ex::ConnectProperties->new
        ([$draw,'expression'],
         [$entry,'text', read_signal => 'activate']);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'Expression' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Square Root'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('The number to take the square root of.  If this is a perfect square then there\'s just a handful of bits to show, non squares go on infinitely.'));
    $toolbar->insert ($toolitem, $toolpos++);

    my $adj = Gtk2::Adjustment->new (1,        # initial
                                     0, 9999999,   # min,max
                                     1,10,     # step,page increment
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'sqrt'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->show;
    $toolitem->set (entry => $spin);

    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'SqrtBits' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Polygonal'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('Which polygonal numbers to show.  3 is the triangular numbers, 4 the perfect squares, 5 the pentagonal numbers, etc.'));
    $toolbar->insert ($toolitem, $toolpos++);

    my $pspec = $draw->find_property ('polygonal');
    my $adj = Gtk2::Adjustment->new ($pspec->get_default_value,  # initial
                                     $pspec->get_minimum,  # min
                                     $pspec->get_maximum,  # max
                                     1,10,     # step,page increment
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'polygonal'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->show;
    $toolitem->set (entry => $spin);

    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'Polygonal' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Multiples'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('Display multiples of this number.  For example 6 means show 6,12,18,24,30,etc.'));
    $toolbar->insert ($toolitem, $toolpos++);

    my $pspec = $draw->find_property ('multiples');
    my $adj = Gtk2::Adjustment->new ($pspec->get_default_value,  # initial
                                     $pspec->get_minimum,  # min
                                     $pspec->get_maximum,  # max
                                     1,10,     # step,page increment
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'multiples'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->show;
    $toolitem->set (entry => $spin);

    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'Multiples' => 1 }]);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
      (enum_type => 'App::MathImage::Gtk2::Drawing::AronsonLang');
    $toolitem->{'name'} = __('Language');
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text  => __('The language to use for the sequence.'));
    $toolitem->show;
    $toolbar->insert ($toolitem, $toolpos++);

    my $combobox = $toolitem->get_child;
    set_property_maybe ($combobox, tearoff_title => $toolitem->{'name'});

    Glib::Ex::ConnectProperties->new ([$draw,'aronson-lang'],
                                      [$combobox,'active-nick']);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'Aronson' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text  => __('The language to use for the sequence.'));
    # $toolitem->signal_connect (create_menu_proxy
    # => \&_do_toolbar_overflow_comboenum);
    $toolbar->insert ($toolitem, $toolpos++);

    my $combobox = Gtk2::Ex::ComboBox::Text->new;
    $combobox->append_text (__('Default'));
    foreach my $letter ('A' .. 'Z') {
      $combobox->append_text ($letter);
    }
    set_property_maybe ($combobox,
                        visible => 1,
                        tearoff_title => __('Letter'));
    $toolitem->add ($combobox);

    Glib::Ex::ConnectProperties->new ([$draw,'aronson-letter'],
                                      [$combobox,'active-text',
                                       func_in => sub {
                                         length($_[0]) == 1
                                           ? $_[0] : __('Default') },
                                       func_out => sub {
                                         length($_[0]) == 1
                                           ? $_[0] : '' },
                                      ]);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$toolitem,'visible',
                                       write_only => 1,
                                       hash_in => { 'Aronson' => 1 }]);
  }
  foreach my $action_name ('AronsonConjunctions', 'AronsonLying') {
    my $action = $actiongroup->get_action ($action_name);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$action,'visible',
                                       write_only => 1,
                                       hash_in => { 'Aronson' => 1 }]);
    if (my $toolitem = $ui->get_widget ("/ui/ToolBar/$action_name")) {
      # move to this position
      $toolbar->remove ($toolitem);
      $toolbar->insert ($toolitem, $toolpos);
    }
  }

  {
    my $separator = Gtk2::SeparatorToolItem->new;
    $separator->show;
    $toolbar->insert ($separator, $toolpos++);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::EnumCombo->new
      (enum_type => 'App::MathImage::Gtk2::Drawing::Filters');
    $toolitem->{'name'} = __('Filter');
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text  => __('Filter the values to only odd, or even, or primes, etc.'));
    $toolitem->show;
    $toolbar->insert ($toolitem, $toolpos++);

    my $combobox = $toolitem->get_child;
    set_property_maybe ($combobox, tearoff_title => $toolitem->{'name'});

    Glib::Ex::ConnectProperties->new
        ([$draw,'filter'],
         [$combobox,'active-nick']);
  }
  {
    my $toolitem = App::MathImage::Gtk2::Ex::ToolItem::Entry->new
      (label => __('Scale'));
    set_property_maybe ($toolitem, # tooltip-text new in 2.12
                        tooltip_text => __('How many pixels per square.'));
    $toolbar->insert ($toolitem, $toolpos++);

    my $hbox = Gtk2::HBox->new;
    $toolitem->set (entry => $hbox);

    $hbox->pack_start (Gtk2::Label->new(__('Scale')), 0,0,0);
    my $adj = Gtk2::Adjustment->new (1,        # initial
                                     1, 999,   # min,max
                                     1,10,     # step,page increment
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'scale'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $hbox->pack_start ($spin, 0,0,0);
    $toolitem->show_all;
  }

  Gtk2::Ex::ActionTooltips::group_tooltips_to_menuitems ($actiongroup);
}

# 'destroy' class closure
sub _do_destroy {
  my ($self) = @_;
  ### Main FINALIZE_INSTANCE(), break circular refs
  delete $self->{'actiongroup'};
  delete $self->{'ui'};
  return shift->signal_chain_from_overridden(@_);
}

sub _do_toolbar_overflow_comboenum {
  my ($toolitem) = @_;
  ### _do_toolbar_overflow_comboenum()
  my $combo = $toolitem->get_child;
  require App::MathImage::Gtk2::Ex::Menu::EnumRadio;
  my $menu = App::MathImage::Gtk2::Ex::Menu::EnumRadio->new
    (enum_type   => $combo->get('enum-type'));
  # tearoff-title new in 2.10, go undef if nothing
  $menu->set_title (eval { $combo->get('tearoff-title') });
  Glib::Ex::ConnectProperties->new ([$combo,'active-nick'],
                                    [$menu,'active-nick']);

  my $menuitem = Gtk2::MenuItem->new_with_label ($combo->{'name'});
  $menuitem->set_submenu ($menu);
  $toolitem->set_proxy_menu_item (__PACKAGE__, $menuitem);
  return 1;
}

# sub _toolbarbits_create_overflow_checkbutton {
#   my ($toolitem) = @_;
#   my $checkbutton = $toolitem->get_child;
#   ### _do_toolbar_overflow_checkbutton(): "$checkbutton"
#   my $buttonlabel = $checkbutton->get_child;
#   my $menuitem = Gtk2::CheckMenuItem->new_with_label ($buttonlabel->get_label);
#   Glib::Ex::ConnectProperties->new ([$checkbutton,'active'],
#                                     [$menuitem,'active']);
#   $toolitem->set_proxy_menu_item (__PACKAGE__, $menuitem);
#   return 1;
# }

# sub _toolbarbits_create_overflow_button {
#   my ($toolitem) = @_;
#   my $button = $toolitem->get_child;
#   ### _toolbarbits_create_overflow_button(): "$button"
#   my $menuitem = Gtk2::MenuItem->new_with_label ($button->get_child->get_label);
#   require Scalar::Util;
#   Scalar::Util::weaken (my $weak_toolitem = $toolitem);
#   $menuitem->signal_connect (activate => sub {
#                                my ($menuitem, $ref_weak_toolitem) = @_;
#                                if (my $toolitem = $$ref_weak_toolitem) {
#                                  $toolitem->activate;
#                                }
#                              }, \$weak_toolitem);
#   $toolitem->set_proxy_menu_item (__PACKAGE__, $menuitem);
#   return 1;
# }

sub _do_motion_notify {
  my ($draw, $event) = @_;
  my $self = $draw->get_ancestor (__PACKAGE__);

  my $statusbar = $self->{'statusbar'};
  my $id = $statusbar->get_context_id (__PACKAGE__);
  $statusbar->pop ($id);

  my ($x, $y, $n) = $draw->pointer_xy_to_image_xyn ($event->x, $event->y);
  if (defined $x) {
    my $message = sprintf ("x=%.*f, y=%.*f",
                           (int($x)==$x ? 0 : 2), $x,
                           (int($y)==$y ? 0 : 2), $y);
    if (defined $n) {
      $message .= "   N=$n";
      my $values = $draw->get('values');
      if ($values ne 'Emirps'
          && (my $radix = $draw->get('values-radix')) != 10) {
        if ($draw->gen_object->values_class->parameters->{'radix'}) {
          my $str = _my_cnv($n,$radix);
          $message .= " ($str in base $radix)";
        }
      }
    }
    $statusbar->push ($id, $message);
  }
  return Gtk2::EVENT_PROPAGATE;
}
sub _my_cnv {
  my ($n, $radix) = @_;
  if ($radix <= 36) {
    require Math::BaseCnv;
    return Math::BaseCnv::cnv($n,10,$radix);
  } else {
    my $ret = '';
    do {
      $ret = sprintf('[%d]', $n % $radix) . $ret;
    } while ($n = int($n/$radix));
    return $ret;
  }  
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;
  ### SET_PROPERTY: $pname, $newval

  if ($pname eq 'fullscreen') {
    # hide the draw widget until fullscreen change takes effect, so as not
    # to do the slow drawing stuff until the new size is set by the window
    # manager
    if ($self->mapped) {
      $self->{'draw'}->hide;
    }
    if ($newval) {
      ### fullscreen
      $self->fullscreen;
    } else {
      ### unfullscreen
      $self->unfullscreen;
    }
  }
  ### SET_PROPERTY done
}

# 'window-state-event' class closure
sub _do_window_state_event {
  my ($self, $event) = @_;
  ### _do_window_state_event: "@{[$event->new_window_state]}"

  my $visible = ! ($event->new_window_state & 'fullscreen');
  $self->toolbar->set (visible => $visible);
  $self->{'statusbar'}->set (visible => $visible);
  $self->{'draw'}->show;

  # reparent the menubar
  my $menubar = $self->menubar;
  my $vbox = ($visible ? $self->{'vbox'} : $self->{'vbox2'});
  if ($menubar->parent != $vbox) {
    $menubar->parent->remove ($menubar);
    $vbox->pack_start ($menubar, 0,0,0);
    $vbox->reorder_child ($menubar, 0); # at the start
    if ($self->{'draw'}->window) {
      $self->{'draw'}->window->raise;
    }
  }
}

sub menubar {
  my ($self) = @_;
  return $self->{'ui'}->get_widget('/MenuBar');
}
sub toolbar {
  my ($self) = @_;
  return $self->{'ui'}->get_widget('/ToolBar');
}

sub popup_save_as {
  my ($self) = @_;
  require App::MathImage::Gtk2::SaveDialog;
  my $dialog = ($self->{'save_dialog'}
                ||= App::MathImage::Gtk2::SaveDialog->new
                (draw => $self->{'draw'},
                 transient_for => $self));
  $dialog->present;
}

# FIXME: better setroot with the X11::Protocol code in App::MathImage when
# possible so as to preserve colormap entries
sub _do_action_setroot {
  my ($action, $self) = @_;
  $self->{'draw'}->start_drawing_window ($self->get_root_window);
}

sub popup_about {
  my ($self) = @_;
  require App::MathImage::Gtk2::AboutDialog;
  my $about = App::MathImage::Gtk2::AboutDialog->new
    (screen => $self->get_screen);
  $about->present;
}

sub _do_action_pod_dialog {
  my ($action, $self) = @_;
  require Gtk2::Ex::WidgetCursor;
  Gtk2::Ex::WidgetCursor->busy;
  require App::MathImage::Gtk2::PodDialog;
  my $dialog = App::MathImage::Gtk2::PodDialog->new
    (screen => $self->get_screen);
  $dialog->present;
}

sub _do_action_random {
  my ($action, $self) = @_;
  $self->{'draw'}->set (App::MathImage::Generator->random_options);
}
sub _do_action_crosshair {
  my ($action, $self) = @_;
  $self->{'crosshair_connp'} ||=  do {
    require Gtk2::Ex::CrossHair;
    require Gtk2::Ex::Units;
    my $draw = $self->{'draw'};
    my $cross = $self->{'crosshair'}
      = Gtk2::Ex::CrossHair->new (widget => $draw,
                                  foreground => 'orange',
                                  active => 1);
    Glib::Ex::ConnectProperties->new ([$action,'active'],
                                      [$cross,'active']);
    my $max_line_width = POSIX::ceil (Gtk2::Ex::Units::width($draw, "1mm"));
    Glib::Ex::ConnectProperties->new ([$draw,'scale'],
                                      [$cross,'line-width',
                                       write_only => 1,
                                       func_in => sub { min($_[0],$max_line_width) }]);
    #     $self->{'draw'}->signal_connect
    #       ('notify::scale' => sub {
    #          my ($draw) = @_;
    #          my $scale = $draw->get('scale');
    #          $cross->set (line_width => min($scale,3));
    #        });
    #     $self->{'draw'}->notify('scale'); # initial
  };
}

my %type_to_adjname = (left  => 'hadjustment',
                       right => 'hadjustment',
                       up    => 'vadjustment',
                       down  => 'vadjustment');
my %type_factor = (left  => -1,
                   right => 1,
                   up    => -1,
                   down  => 1);
sub _do_arrow_button_clicked {
  my ($button) = @_;
  my $self = $button->get_ancestor (__PACKAGE__);
  my $arrow = $button->get_child;
  my $type = $arrow->get('arrow-type');
  ### _do_arrow_button_clicked(): $type
  my $adj = $self->{'draw'}->get($type_to_adjname{$type});

  ### adj value was: $adj->value.' page='.$adj->page_size
  ### add: $adj->step_increment
  ### value upper limit: $adj->upper - $adj->page_size
  $adj->set_value ($adj->value + $adj->step_increment * $type_factor{$type});
  ### adj value now: $adj->value
}

my %orientation_to_adjname = (horizontal => 'hadjustment',
                              vertical   => 'vadjustment');
my %orientation_to_cursorname = (horizontal => 'sb-h-double-arrow',
                                 vertical   => 'sb-v-double-arrow');
# axis 'button-press-event' handler
sub _do_axis_button_press {
  my ($axis, $event) = @_;
  if ($event->button == 1) {
    my $dragger = ($axis->{'dragger'} ||= do {
      my $self = $axis->get_ancestor (__PACKAGE__);
      my $orientation = $axis->get('orientation');
      my $adjname = $orientation_to_adjname{$orientation};
      my $adj = $self->{'draw'}->get($adjname);
      require Gtk2::Ex::Dragger;
      Gtk2::Ex::Dragger->new (widget    => $axis,
                              $adjname  => $adj,
                              vinverted => 1,
                              cursor    => $orientation_to_cursorname{$orientation})
      });
    $dragger->start ($event);
  }
  return Gtk2::EVENT_PROPAGATE;
}

#------------------------------------------------------------------------------
# printing

sub print_image {
  my ($self) = @_;
  my $print = Gtk2::PrintOperation->new;
  $print->set_n_pages (1);
  if (my $settings = $self->{'print_settings'}) {
    $print->set_print_settings ($settings);
  }
  Scalar::Util::weaken (my $weak_self = $self);
  $print->signal_connect (draw_page => \&_draw_page, \$weak_self);

  my $result = $print->run ('print-dialog', $self);
  if ($result eq 'apply') {
    $self->{'print_settings'} = $print->get_print_settings;
  }
}

sub _draw_page {
  my ($print, $pcontext, $pagenum, $ref_weak_self) = @_;
  ### _draw_page()
  my $self = $$ref_weak_self || return;
  my $c = $pcontext->get_cairo_context;

  my $draw = $self->{'draw'};
  my $gen = $draw->gen_object;
  my $str = $gen->description . "\n\n";

  my $pwidth = $pcontext->get_width;
  my $layout = $pcontext->create_pango_layout;
  $layout->set_width ($pwidth * Gtk2::Pango::PANGO_SCALE);
  $layout->set_text ($str);
  my (undef, $str_height) = $layout->get_pixel_size;
  ### $str_height
  $c->move_to (0, 0);
  Gtk2::Pango::Cairo::show_layout ($c, $layout);

  my $pixmap = $draw->pixmap;
  my $pixmap_context = Gtk2::Gdk::Cairo::Context->create ($pixmap);
  my ($pixmap_width, $pixmap_height) = $pixmap->get_size;
  ### $pixmap_width
  ### $pixmap_height

  my $pheight = $pcontext->get_height - $str_height;
  ### $pwidth
  ### $pheight
  $c->translate (0, $str_height);
  my $factor = min ($pwidth / $pixmap_width,
                    $pheight / $pixmap_height);

  if ($factor < 1) {
    $c->scale ($factor, $factor);
  }
  $c->set_source_surface ($pixmap_context->get_target, 0,0);

  $c->rectangle (0,0, $pixmap_width,$pixmap_height);
  $c->paint;
}

1;
