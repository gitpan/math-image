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
use Module::Util;
use Glib::Ex::ConnectProperties 8;  # v.7 for transforms, v.8 for write_only
use Gtk2::Ex::ActionTooltips;
use Locale::TextDomain 1.19 ('App-MathImage');
use Locale::Messages 'dgettext';
use App::MathImage::Gtk2::Drawing;
use App::MathImage::Gtk2::Drawing::Values;
use App::MathImage::Gtk2::Ex::ComboBox::EnumValues;
use App::MathImage::Glib::Ex::EnumBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 15;

use Glib::Object::Subclass
  'Gtk2::Window',
  signals => { window_state_event => \&_do_window_state_event },
  properties => [ Glib::ParamSpec->boolean
                  ('fullscreen',
                   'fullscreen',
                   'Blurb.',
                   0,           # default
                   Glib::G_PARAM_READWRITE),
                ];

my %_values_to_mnemonic =
  (primes        => __('_Primes'),
   twin_primes   => __('_Twin Primes'),
   twin_primes_1 => __('Twin Primes _1'),
   twin_primes_2 => __('Twin Primes _2'),
   squares       => __('S_quares'),
   pronic        => __('Pro_nic'),
   triangular    => __('Trian_gular'),
   cubes         => __('_Cubes'),
   tetrahedral   => __('_Tetrahedral'),
   perrin        => __('Perr_in'),
   padovan       => __('Pado_van'),
   fibonacci     => __('_Fibonacci'),
   fraction_bits => __('F_raction Bits'),
   polygonal     => __('Pol_ygonal Numbers'),
   pi_bits       => __('_Pi Bits'),
   ln2_bits      => __x('_Log Natural {logarg} Bits', logarg => 2),
   ln3_bits      => __x('_Log Natural {logarg} Bits', logarg => 3),
   ln10_bits     => __x('_Log Natural {logarg} Bits', logarg => 10),
   odd           => __('_Odd Integers'),
   even          => __('_Even Integers'),
   all           => __('_All Integers'),
  );
sub _values_to_mnemonic {
  my ($str) = @_;
  return ($_values_to_mnemonic{$str}
          || App::MathImage::Glib::Ex::EnumBits->to_text_default($str));
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
          || App::MathImage::Glib::Ex::EnumBits::to_text_default($str));
}

my $set_tooltip_text;
BEGIN {
  $set_tooltip_text = (Gtk2::Widget->can('set_tooltip_text')
                       ? 'set_tooltip_text'  # new in 2.12
                       : sub {});  # dummy
}

sub INIT_INSTANCE {
  my ($self) = @_;

  my $vbox = $self->{'vbox'} = Gtk2::VBox->new (0, 0);
  $vbox->show;
  $self->add ($vbox);

  my $draw = $self->{'draw'} = App::MathImage::Gtk2::Drawing->new;
  $draw->show;

  my $actiongroup = $self->{'actiongroup'} = Gtk2::ActionGroup->new ('main');
  Gtk2::Ex::ActionTooltips::group_tooltips_to_menuitems ($actiongroup);

  $actiongroup->add_actions
    ([                          # name,        stock-id,  label
      [ 'FileMenu',   undef,    dgettext('gtk20-properties','_File')  ],
      [ 'ViewMenu',   undef,    dgettext('gtk20-properties','_View')  ],
      [ 'ToolsMenu',  undef,    dgettext('gtk20-properties','_Tools')  ],
      [ 'HelpMenu',   undef,    dgettext('gtk20-properties','_Help')  ],

      # name,       stock id,     label,  accelerator,  tooltip

      { name     => 'SaveAs',
        stock_id => 'gtk-save-as',
        callback => \&_do_action_save_as,
        tooltip  => __('Save the image to a file.'),
      },
      { name     => 'SetRoot',
        label    => 'Set _Root Window',
        callback => \&_do_action_setroot,
        tooltip  => __('Set the current image as the root window background.'),
      },
      [ 'Quit',     'gtk-quit',   undef,
        __p('Main-accelerator-key','<Control>Q'),
        undef, \&_do_action_quit,
      ],

      { name     => 'About',
        stock_id => 'gtk-about',
        callback => \&_do_action_about,
      },

      { name     => 'Random',
        label    => __('Random'),
        callback => \&_do_action_random,
        tooltip  => __('Choose a random path, values, scale, etc.  Click repeatedly to see interesting things.'),
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
                                          label => __('_Draw Progressive'),
                                          tooltip => __('Whether to draw progressively on the screen, or show the final image when ready.'));
    $actiongroup->add_action ($action);
    Glib::Ex::ConnectProperties->new ([$draw,  'draw-progressive'],
                                      [$action,'active']);
  }
  $actiongroup->add_toggle_actions
    ([ { name => 'Toolbar',
         label => __('_Toolbar'),
         tooltip => __('Whether to show the toolbar.')},
     ]);

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
      <menuitem action='SaveAs'/>
      <menuitem action='SetRoot'/>
      <menuitem action='Quit'/>
    </menu>
    <menu action='ViewMenu'>
HERE
  foreach my $values (App::MathImage::Generator->values_choices) {
    $ui_str .= "      <menuitem action='Values-$values'/>\n";
  }
  $ui_str .= "      <separator/>\n";
  foreach my $path (App::MathImage::Generator->path_choices) {
    $ui_str .= "      <menuitem action='Path-$path'/>\n";
  }
  $ui_str .= <<'HERE';
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
    </menu>
    <menu action='HelpMenu'>
      <menuitem action='About'/>
    </menu>
  </menubar>
  <toolbar  name='ToolBar'>
    <toolitem action='Random'/>
    <separator/>
  </toolbar>
</ui>
HERE
  $ui->add_ui_from_string ($ui_str);

  my $menubar = $self->menubar;
  $menubar->show;
  $vbox->pack_start ($menubar, 0,0,0);

  my $toolbar = $self->toolbar;
  $vbox->pack_start ($toolbar, 0,0,0);

  my $table = $self->{'table'} = Gtk2::Table->new (1, 1);
  $vbox->pack_start ($table, 1,1,0);

  my $vbox2 = $self->{'vbox2'} = Gtk2::VBox->new;
  $table->attach ($vbox2, 0,1, 0,1, ['expand','fill'],['expand','fill'],0,0);

  $draw->add_events ('pointer-motion-mask');
  $draw->signal_connect (motion_notify_event => \&_do_motion_notify);
  $table->attach ($draw, 0,1, 0,1, ['expand','fill'],['expand','fill'],0,0);

  my $statusbar = $self->{'statusbar'} = Gtk2::Statusbar->new;
  $vbox->pack_start ($statusbar, 0,0,0);

  my $renderer1 = Gtk2::CellRendererText->new;
  $renderer1->set (ypad => 0);

  {
    my $action = $actiongroup->get_action ('Toolbar');
    Glib::Ex::ConnectProperties->new ([$toolbar,'visible'],
                                      [$action,'active']);
  }

  my $toolpos = -999;
  my $path_combobox;
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    $path_combobox = $self->{'path_combobox'}
      = App::MathImage::Gtk2::Ex::ComboBox::EnumValues->new
        (enum_type => 'App::MathImage::Gtk2::Drawing::Path');
    _set_property_if_exists ($path_combobox, tearoff_title => __('Path'));
    $path_combobox->$set_tooltip_text(__('The path for where to place values in the plane.'));
    $toolitem->add ($path_combobox);

    Glib::Ex::ConnectProperties->new ([$draw,'path'],
                                      [$path_combobox,'active-nick']);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $adj = Gtk2::Adjustment->new (0,       # initial
                                     0, 999,  # min,max
                                     1,10,    # steps
                                     0);      # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'path-wider'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->$set_tooltip_text(__('Wider path.'));
    $toolitem->add ($spin);
    Glib::Ex::ConnectProperties->new ([$path_combobox,'active-nick'],
                                      [$spin,'visible',
                                       write_only => 1,
                                       hash_in => { 'SquareSpiral' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $adj = Gtk2::Adjustment->new (2,       # initial
                                     1, 12,   # min,max
                                     1,1,     # steps
                                     0);      # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'pyramid_step'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->$set_tooltip_text(__('Step width for the pyramid rows, half going to each side.'));
    $toolitem->add ($spin);
    Glib::Ex::ConnectProperties->new ([$path_combobox,'active-nick'],
                                      [$spin,'visible',
                                       write_only => 1,
                                       hash_in => { 'PyramidRows' => 1 }]);
  }

  my $values_combobox;
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    $values_combobox = $self->{'values_combobox'}
      = App::MathImage::Gtk2::Ex::ComboBox::EnumValues->new
        (enum_type => 'App::MathImage::Gtk2::Drawing::Values');
    $toolitem->add ($values_combobox);
    _set_property_if_exists ($values_combobox, tearoff_title => __('Values'));

    $values_combobox->signal_connect
      ('notify::nick' => sub {
         my ($values_combobox) = @_;
         my $values = $values_combobox->get('active-nick');
         my $tooltip = __('The values to display.');
         my $enum_type = $values_combobox->get('enum_type');
         if (my $desc = App::MathImage::Glib::Ex::EnumBits::to_description
             ($enum_type, $values)) {
           my $name = App::MathImage::Glib::Ex::EnumBits::to_text
             ($enum_type, $values);
           $tooltip .= "\n\n"
             . __x('Current setting: {name}', name => $name)
               . "\n"
                 . $desc;
         }
         ### $tooltip
         $values_combobox->$set_tooltip_text ($tooltip);
       });

    Glib::Ex::ConnectProperties->new ([$draw,'values'],
                                      [$values_combobox,'active-nick']);
    ### values combobox initial: $values_combobox->get('active-nick')
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);
    my $liststore = Gtk2::ListStore->new('Glib::String','Glib::String');
    $liststore->set ($liststore->append, 0 => 'all',    1 => __('All'));
    $liststore->set ($liststore->append, 0 => 'primes', 1 => __('Primes'));
    my $combobox = Gtk2::ComboBox->new ($liststore);
    _set_property_if_exists ($combobox,
                             tearoff_title => __('Prime Quadratic Filter'));
    $combobox->$set_tooltip_text(__('Optionally show only the primes among the prime generating polynomials.'));
    $toolitem->add ($combobox);

    $combobox->pack_start ($renderer1, 1);
    $combobox->set_attributes ($renderer1, text => 1);

    Glib::Ex::ConnectProperties->new
        ([$draw,'prime-quadratic'],
         [$combobox,'active',
          hash_in  => { all => 0, primes => 1 },
          hash_out => { 0 => 'all', 1 => 'primes' } ]);
    Glib::Ex::ConnectProperties->new
        ([$values_combobox,'active-nick'],
         [$combobox,'visible',
          write_only => 1,
          func_in => sub {
            my ($values) = @_;
            return ($values && $values =~ /^prime_quadratic/);
          }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $entry = $self->{'fraction_entry'} = Gtk2::Entry->new;
    $entry->set_width_chars (8);
    $entry->$set_tooltip_text(__('The fraction to show, for example 5/29.'));
    $toolitem->add ($entry);
    Glib::Ex::ConnectProperties->new
        ([$draw,'fraction'],
         [$entry,'text']);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$entry,'visible',
                                       write_only => 1,
                                       hash_in => { 'fraction_bits' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $entry = $self->{'expression_entry'} = Gtk2::Entry->new;
    $entry->set_width_chars (30);
    $entry->$set_tooltip_text(__('A mathematical expression giving values to display, for example x^2+x+41.  Only one variable is allowed, see Math::Symbolic for possible operators and function.'));
    $toolitem->add ($entry);
    Glib::Ex::ConnectProperties->new
        ([$draw,'expression'],
         [$entry,'text']);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$entry,'visible',
                                       write_only => 1,
                                       hash_in => { 'expression' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $adj = Gtk2::Adjustment->new (1,        # initial
                                     0, 9999999,   # min,max
                                     1,10,     # steps
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'sqrt'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->$set_tooltip_text(__('The number to take the square root of.  If this is a perfect square then there\'s just a handful of bits to show, non squares go on infinitely.'));
    $toolitem->add ($spin);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$spin,'visible',
                                       write_only => 1,
                                       hash_in => { 'sqrt_bits' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $adj = Gtk2::Adjustment->new (1,        # initial
                                     2, 999,   # min,max
                                     1,10,     # steps
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'polygonal'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->$set_tooltip_text(__('Which polygonal numbers to show.  3 is the triangular numbers, 4 the perfect squares, 5 the pentagonal numbers, etc.'));
    $toolitem->add ($spin);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$spin,'visible',
                                       write_only => 1,
                                       hash_in => { 'polygonal' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $adj = Gtk2::Adjustment->new (1,        # initial
                                     -99_999_999, 99_999_999,   # min,max
                                     1,10,     # steps
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'multiples'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->$set_tooltip_text(__('Display multiples of this number.  For example 6 means show 6,12,18,24,30,etc.'));
    $toolitem->add ($spin);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$spin,'visible',
                                       write_only => 1,
                                       hash_in => { 'multiples' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $combobox = Gtk2::ComboBox->new_text;
    $combobox->append_text (__('English'));
    $combobox->append_text (__('French'));
    $combobox->$set_tooltip_text(__('The language to use for the sequence.'));
    $toolitem->add ($combobox);
    Glib::Ex::ConnectProperties->new ([$draw,'aronson-lang'],
                                      [$combobox,'active',
                                       hash_in => { 'en' => 0,
                                                    'fr' => 1 },
                                       hash_out => { 0 => 'en',
                                                     1 => 'fr' }]);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$combobox,'visible',
                                       write_only => 1,
                                       hash_in => { 'aronson' => 1 }]);
  }
  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $check = Gtk2::CheckButton->new_with_label (__('Conjunctions'));
    $check->$set_tooltip_text(__('Whether to include conjunctions "and" or "et" in the words of the sequence.'));
    $toolitem->add ($check);
    Glib::Ex::ConnectProperties->new ([$draw,'aronson-conjunctions'],
                                      [$check,'active']);
    Glib::Ex::ConnectProperties->new ([$values_combobox,'active-nick'],
                                      [$check,'visible',
                                       write_only => 1,
                                       hash_in => { 'aronson' => 1 }]);
  }

  {
    my $toolitem = Gtk2::ToolItem->new;
    $toolbar->insert ($toolitem, $toolpos++);

    my $hbox = Gtk2::HBox->new;
    $toolitem->add ($hbox);
    $hbox->pack_start (Gtk2::Label->new(__('Scale')), 0,0,0);
    my $adj = Gtk2::Adjustment->new (1,        # initial
                                     1, 999,   # min,max
                                     1,10,     # steps
                                     0);       # page_size
    Glib::Ex::ConnectProperties->new ([$draw,'scale'],
                                      [$adj,'value']);
    my $spin = Gtk2::SpinButton->new ($adj, 10, 0);
    $spin->$set_tooltip_text(__('How many pixels per square.'));
    $hbox->pack_start ($spin, 0,0,0);
  }

  Gtk2::Ex::ActionTooltips::group_tooltips_to_menuitems
      ($actiongroup);

  ### draw: $draw->get('aronson_lang')
  $vbox->show_all;
  $path_combobox->notify('active');    # initial spinners
  $values_combobox->notify('active');  # initial spinners
}

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
    }
    $statusbar->push ($id, $message);
  }
  return 0;                     # Gtk2::EVENT_PROPAGATE
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

sub _do_action_save_as {
  my ($action, $self) = @_;
  $self->popup_save_as;
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

sub _do_action_setroot {
  my ($action, $self) = @_;
  $self->{'draw'}->start_drawing_window ($self->get_root_window);
}
sub _do_action_quit {
  my ($action, $self) = @_;
  $self->destroy;
}

sub _do_action_about {
  my ($action, $self) = @_;
  $self->popup_about;
}
sub popup_about {
  my ($self) = @_;
  require App::MathImage::Gtk2::AboutDialog;
  my $about = App::MathImage::Gtk2::AboutDialog->new
    (screen => $self->get_screen);
  $about->present;
}

sub _do_action_random {
  my ($action, $self) = @_;
  $self->{'draw'}->set (App::MathImage::Generator->random_options);
}
sub _do_action_crosshair {
  my ($action, $self) = @_;
  $self->{'crosshair_connect'} ||= do {
    require Gtk2::Ex::CrossHair;
    my $cross = $self->{'crosshair'}
      = Gtk2::Ex::CrossHair->new (widget => $self->{'draw'},
                                  foreground => 'orange',
                                  active => 1);
    Glib::Ex::ConnectProperties->new ([$action,'active'],
                                      [$cross,'active']);
    $self->{'draw'}->signal_connect
      ('notify::scale' => sub {
         my ($draw) = @_;
         my $self = $draw->get_ancestor (__PACKAGE__);
         my $scale = $draw->get('scale');
         $cross->set (line_width => min($scale,3));
       });
    $self->{'draw'}->notify('scale'); # initial
  };
}

sub _set_property_if_exists {
  my $object = shift;
  if (@_ & 1) {
    croak "_set_property_if_exists expect even number of propname,value arguments";
  }
  while (@_) {
    my $pname = shift;
    my $value = shift;
    if ($object->find_property($pname)) {
      $object->set_property ($pname, $value);
    }
  }
}

1;
