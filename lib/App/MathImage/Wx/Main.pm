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


package App::MathImage::Wx::Main;
use strict;
use Wx;
use Wx::Event 'EVT_MENU';
use Locale::TextDomain ('Math-Image');

use App::MathImage::Generator;
use App::MathImage::Wx::Drawing;
use App::MathImage::Wx::Params;

use base qw(Wx::Frame);

# uncomment this to run the ### lines
#use Smart::Comments;


our $VERSION = 104;

sub new {
  my ($class, $label) = @_;
  my $self = $class->SUPER::new (undef,
                                 Wx::wxID_ANY(),
                                 $label);
  $self->{'position_status'} = '';

  # load an icon and set it as frame icon
  $self->SetIcon (Wx::GetWxPerlIcon());

  my $menubar = Wx::MenuBar->new;
  $self->SetMenuBar ($menubar);

  {
    my $menu = Wx::Menu->new;
    $menubar->Append ($menu, __('&File'));

    $menu->Append(Wx::wxID_EXIT(),
                  '',
                  __('Exit the program'));
    EVT_MENU ($self, Wx::wxID_EXIT(), 'quit');
  }
  {
    my $menu = Wx::Menu->new;
    $menubar->Append ($menu, __('&Tools'));
    {
      my $item = $self->{'fullscreen_menuitem'} =
        $menu->Append (Wx::wxID_ANY(),
                       __("&Fullscreen\tCtrl-F"),
                       __("Toggle full screen or normal window (use accelerator Ctrl-F to return from fullscreen)."),
                       Wx::wxITEM_CHECK());
      EVT_MENU ($self, $item, 'fullscreen_toggle');
      Wx::Event::EVT_UPDATE_UI ($self, $item, \&_update_ui_fullscreen_menuitem);
    }
    {
      my $item = $menu->Append(Wx::wxID_ANY(),
                               __("&Centre\tC"),
                               __('Scroll to centre the origin 0,0 on screen (or at the left or bottom if no negatives in the path).'));
      EVT_MENU ($self, $item, '_menu_centre');
    }
    {
      my $submenu = Wx::Menu->new (__('Toolbar'));
      {
        my $item = $submenu->AppendRadioItem
          (Wx::wxID_ANY(),
           __("&Horizontal"),
           __('Toolbar horizontal across the top of the window.'));
        EVT_MENU ($self, $item, '_toolbar_horizontal');
      }
      {
        my $item = $submenu->AppendRadioItem
          (Wx::wxID_ANY(),
           __("&Vertical"),
           __('Toolbar vertically at the left of the window.'));
        EVT_MENU ($self, $item, '_toolbar_vertical');
      }
      {
        my $item = $submenu->AppendRadioItem
          (Wx::wxID_ANY(),
           __("Hi&de"),
           __('Hide the toolbar.'));
        EVT_MENU ($self, $item, '_toolbar_hide');
      }
      $menu->AppendSubMenu ($submenu, __('&Toolbar'));
    }
  }
  {
    my $menu = $self->{'help_menu'} = Wx::Menu->new;
    $menubar->Append ($menu, __('&Help'));

    $menu->Append (Wx::wxID_ABOUT(),
                   '',
                   __('Show about dialog'));
    EVT_MENU ($self, Wx::wxID_ABOUT(), 'popup_about');

    {
      my $item = $menu->Append (Wx::wxID_ANY(),
                                __('&Program POD'),
                                __('Show the values POD'));
      EVT_MENU ($self, $item, 'popup_program_pod');
    }
    {
      my $item = $menu->Append (Wx::wxID_ANY(),
                                __('Pa&th POD'),
                                __('Show the program POD'));
      EVT_MENU ($self, $item, 'popup_path_pod');
    }
    {
      my $item = $menu->Append (Wx::wxID_ANY(),
                                __('&Values POD'),
                                __('Show the path POD'));
      EVT_MENU ($self, $item, 'popup_values_pod');
    }

    {
      my $item
        = $self->{'help_oeis_menuitem'}
          = $menu->Append (Wx::wxID_ANY(),
                           __('&OEIS Web Page'),
                           ''); # tooltip set by oeis_browse_update()
      EVT_MENU ($self, $item, 'oeis_browse');
    }
  }

  {
    my $toolbar = $self->{'toolbar'} = $self->CreateToolBar;
    # (Wx::wxTB_VERTICAL());

    # my $bitmap = Wx::Bitmap->new (10,10);
    # $toolbar->AddTool(Wx::wxID_ANY(),
    #                   __('&Randomize'),
    #                   $bitmap, # Wx::wxNullBitmap(),
    #                   "Random path, values, etc",
    #                   Wx::wxITEM_NORMAL());
    # EVT_MENU ($self, $item, 'randomize');

    {
      my $button = Wx::Button->new ($toolbar, Wx::wxID_ANY(), __('Randomize'));
      $toolbar->AddControl($button);
      $toolbar->SetToolShortHelp ($button->GetId,
                                  __("Random path, values, etc"));
      Wx::Event::EVT_BUTTON ($self, $button, 'randomize');
    }

    {
      my $choice = $self->{'path_choice'}
        = Wx::Choice->new ($toolbar,
                           Wx::wxID_ANY(),
                           Wx::wxDefaultPosition(),
                           Wx::wxDefaultSize(),
                           [App::MathImage::Generator->path_choices]);
      # 0,  # style
      # Wx::wxDefaultValidator(),
      $toolbar->AddControl($choice);
      $toolbar->SetToolShortHelp
        ($choice->GetId,
         __('The path for where to place values in the plane.'));
      Wx::Event::EVT_CHOICE ($self, $choice, 'path_update');

      my $path_params = $self->{'path_params'}
        = App::MathImage::Wx::Params->new
          (toolbar => $toolbar,
           after_item => $choice,
           callback => sub { path_params_update($self) });
    }

    {
      my $choice = $self->{'values_choice'}
        = Wx::Choice->new ($toolbar,
                           Wx::wxID_ANY(),
                           Wx::wxDefaultPosition(),
                           Wx::wxDefaultSize(),
                           [App::MathImage::Generator->values_choices]);
      # 0,  # style
      # Wx::wxDefaultValidator(),
      $toolbar->AddControl($choice);
      $toolbar->SetToolShortHelp
        ($choice->GetId,
         __('The values to show.'));
      Wx::Event::EVT_CHOICE ($self, $choice, 'values_update');

      my $values_params = $self->{'values_params'}
        = App::MathImage::Wx::Params->new
          (toolbar => $toolbar,
           after_item => $choice,
           callback => sub { values_params_update($self) });
    }

    #    $toolbar->AddSeparator;

    {
      my $choice = $self->{'filter_choice'}
        = Wx::Choice->new ($toolbar,
                           Wx::wxID_ANY(),
                           Wx::wxDefaultPosition(),
                           Wx::wxDefaultSize(),
                           [ App::MathImage::Generator->filter_choices_display ]);
      $toolbar->AddControl($choice);
      $toolbar->SetToolShortHelp
        ($choice->GetId,
         __('Filter the values to only odd, or even, or primes, etc.'));
      Wx::Event::EVT_CHOICE ($self, $choice, 'filter_update');
    }
    {
      my $spin = $self->{'scale_spin'}
        = Wx::SpinCtrl->new ($toolbar,
                             Wx::wxID_ANY(),
                             3,  # initial value
                             Wx::wxDefaultPosition(),
                             Wx::Size->new(40,-1),
                             Wx::wxSP_ARROW_KEYS(),
                             1,                  # min
                             POSIX::INT_MAX(),   # max
                             3);                 # initial
      $toolbar->AddControl($spin);
      $toolbar->SetToolShortHelp ($spin->GetId,
                                  __('How many pixels per square.'));
      Wx::Event::EVT_SPINCTRL ($self, $spin, 'scale_update');
    }
    {
      my @figure_display = map {ucfirst}
        App::MathImage::Generator->figure_choices;
      $figure_display[0] = __('Figure');
      my $choice = $self->{'figure_choice'}
        = Wx::Choice->new ($toolbar,
                           Wx::wxID_ANY(),
                           Wx::wxDefaultPosition(),
                           Wx::wxDefaultSize(),
                           \@figure_display);
      $toolbar->AddControl($choice);
      $toolbar->SetToolShortHelp
        ($choice->GetId,
         __('The figure to draw at each position.'));
      Wx::Event::EVT_CHOICE ($self, $choice, 'figure_update');
    }
  }

  $self->CreateStatusBar;

  my $draw = $self->{'draw'} = App::MathImage::Wx::Drawing->new ($self);
  _controls_from_draw ($self);
  # $self->values_update_tooltip;
  # $self->oeis_browse_update;

  return $self;
}

use constant FULLSCREEN_HIDE_BITS => Wx::wxFULLSCREEN_ALL();
# & ~ Wx::wxFULLSCREEN_NOMENUBAR();
sub fullscreen_toggle {
  my ($self, $event) = @_;
  ### Wx-Main fullscreen_toggle() ...
  $self->ShowFullScreen (! $self->IsFullScreen, FULLSCREEN_HIDE_BITS);
}
sub _update_ui_fullscreen_menuitem {
  my ($self, $event) = @_;
  ### Wx-Main _update_ui_fullscreen_menuitem: "@_"
  # though if FULLSCREEN_HIDE_BITS hides the menubar then the item won't be
  # seen when checked ...
  $self->{'fullscreen_menuitem'}->Check ($self->IsFullScreen);
}
sub _menu_centre {
  my ($self, $event) = @_;
  ### Main _menu_fullscreen() ...

  my $draw = $self->{'draw'};
  if ($draw->{'x_offset'} != 0 || $draw->{'y_offset'} != 0) {
    $draw->{'x_offset'} = 0;
    $draw->{'y_offset'} = 0;
    $draw->redraw;
  }
}

sub _toolbar_horizontal {
  my ($self, $event) = @_;
  my $toolbar = $self->{'toolbar'};

  my $style = $toolbar->GetWindowStyleFlag;
  $style &= ~ Wx::wxTB_VERTICAL();
  $style |= Wx::wxTB_HORIZONTAL();
  $toolbar->SetWindowStyleFlag($style);

  $toolbar->Show;
  $self->SetToolBar(undef);
  $self->SetToolBar($toolbar);
}
sub _toolbar_vertical {
  my ($self, $event) = @_;
  my $toolbar = $self->{'toolbar'};

  my $style = $toolbar->GetWindowStyleFlag;
  $style &= ~ Wx::wxTB_HORIZONTAL();
  $style |= Wx::wxTB_VERTICAL();
  $toolbar->SetWindowStyleFlag($style);

  $toolbar->Show;
  $self->SetToolBar(undef);
  $self->SetToolBar($toolbar);
}
sub _toolbar_hide {
  my ($self, $event) = @_;
  my $toolbar = $self->{'toolbar'};
  $toolbar->Hide;
  $self->SetToolBar(undef);
  $self->SetToolBar($toolbar);
}

sub oeis_browse {
  my ($self, $event) = @_;
  if (my $url = $self->oeis_url) {
    Wx::LaunchDefaultBrowser($url);
  }
}
sub oeis_url {
  my ($self) = @_;
  if (my $anum = $self->oeis_anum) {
    return "http://oeis.org/$anum";
  }
  return undef;
}
sub oeis_anum {
  my ($self) = @_;
  if (my $gen_object = $self->{'draw'}->gen_object_maybe) {
    return $gen_object->oeis_anum;
  }
  return undef;
}

sub randomize {
  my ($self, $event) = @_;
  ### Main randomize() ...

  my $draw = $self->{'draw'};
  my %options = App::MathImage::Generator->random_options;
  @{$draw}{keys %options} = values %options;
  _controls_from_draw ($self);
  $draw->redraw;
  $self->values_update_tooltip;
  $self->oeis_browse_update;
}
sub scale_update {
  my ($self, $event) = @_;
  ### Main scale_update() ...
  my $draw = $self->{'draw'};
  $draw->{'scale'} = $self->{'scale_spin'}->GetValue;
  $draw->redraw;
}
sub filter_update {
  my ($self, $event) = @_;
  ### Main filter_update() ...
  my $draw = $self->{'draw'};
  my @filter_choices = App::MathImage::Generator->filter_choices;
  $draw->{'filter'} = $filter_choices[$self->{'filter_choice'}->GetSelection];
  $draw->redraw;
}
sub figure_update {
  my ($self, $event) = @_;
  ### Main figure_update() ...
  my $draw = $self->{'draw'};
  my @figure_choices = App::MathImage::Generator->figure_choices;
  $draw->{'figure'} = $figure_choices[$self->{'figure_choice'}->GetSelection];
  $draw->redraw;
}
sub path_update {
  my ($self) = @_;  # ($self, $event)
  ### Wx-Main path_update(): "$self"
  my $draw = $self->{'draw'};
  my $path = $draw->{'path'} = $self->{'path_choice'}->GetStringSelection;
  $self->{'path_params'}->SetParameterInfoArray
    (App::MathImage::Generator->path_class($path)->parameter_info_array);
  $draw->redraw;
}
sub path_params_update {
  my ($self) = @_;
  ### Main path_parameters_update(): "$self"
  my $draw = $self->{'draw'};
  my $path_params = $self->{'path_params'};
  $draw->{'path_parameters'} = $path_params->GetParameterValues;
  $draw->redraw;
}
sub values_update {
  my ($self, $event) = @_;
  ### Wx-Main values_update() ...
  my $draw = $self->{'draw'};
  my $values = $draw->{'values'} = $self->{'values_choice'}->GetStringSelection;
  $self->{'values_params'}->SetParameterInfoArray
    (App::MathImage::Generator->values_class($values)->parameter_info_array);
  $draw->redraw;
  $self->values_update_tooltip;
  $self->oeis_browse_update;
}
sub values_params_update {
  my ($self) = @_;
  ### Wx-Main values_parameters_update(): "$self"
  my $draw = $self->{'draw'};
  my $values_params = $self->{'values_params'};
  $draw->{'values_parameters'} = $values_params->GetParameterValues;
  $draw->redraw;
  $self->values_update_tooltip;
  $self->oeis_browse_update;
}
sub values_update_tooltip {
  my ($self) = @_;
  ### Wx-Main values_update_tooltip() ...

  my $tooltip = __('The values to display.');
  my $values_choice = $self->{'values_choice'};

  if (my $gen_object = $self->{'draw'}->gen_object_maybe) {
    if (my $values_seq = $gen_object->values_seq_maybe) {
      if (my $desc = $values_seq->description) {
        my $name = $values_choice->GetStringSelection;
        ### values_seq name: "$values_seq"
        ### values_choice name: $name
        $tooltip .= "\n\n"
          . __x('Current setting: {name}', name => $name)
            . "\n$desc";
      }
    }
  }

  my $toolbar = $self->{'toolbar'};
  $toolbar->SetToolShortHelp ($values_choice->GetId, $tooltip);
}
sub oeis_browse_update {
  my ($self) = @_;
  my $item = $self->{'help_oeis_menuitem'};
  my $menu = $self->{'help_menu'};
  my $url = $self->oeis_url;
  $menu->Enable ($item, defined($url));
  $menu->SetHelpString ($item->GetId,
                        __x("Open browser at Online Encyclopedia of Integer Sequences (OEIS) web page for the current values\n{url}",
                            url => ($url||'')));
}



sub _controls_from_draw {
  my ($self) = @_;
  ### _controls_from_draw() ...
  ### path: $self->{'draw'}->{'path'}
  ### values: $self->{'draw'}->{'values'}
  ### draw seq: ($self->{'draw'}->gen_object->values_seq || '').''

  my $draw = $self->{'draw'};
  my $path = $draw->{'path'};
  $self->{'path_choice'}->SetStringSelection ($path);
  $self->{'path_params'}->SetParameterInfoArray
    (App::MathImage::Generator->path_class($path)->parameter_info_array);
  $self->{'path_params'}->SetParameterValues ($draw->{'path_parameters'} || {});

  my $values = $draw->{'values'};
  $self->{'values_choice'}->SetStringSelection ($values);
  $self->{'values_params'}->SetParameterInfoArray
    (App::MathImage::Generator->values_class($values)->parameter_info_array);
  $self->{'values_params'}->SetParameterValues ($draw->{'values_parameters'} || {});

  $self->{'scale_spin'}->SetValue ($draw->{'scale'});
  $self->{'figure_choice'}->SetStringSelection ($draw->{'figure'});

  $self->values_update_tooltip;
  $self->oeis_browse_update;
}

sub quit {
  my ($self, $event) = @_;
  $self->Close;
}

#------------------------------------------------------------------------------
# help

sub popup_about {
  my ($self, $event) = @_;
  ### Main popup_about() ...
  # require App::MathImage::Wx::AboutDialog;
  # App::MathImage::Wx::About->new;

  my $info = Wx::AboutDialogInfo->new;
  $info->SetName(__("Math-Image"));
  # $info->SetIcon('...');
  $info->SetVersion($self->VERSION);
  $info->SetWebSite('http://user42.tuxfamily.org/math-image/index.html');

  $info->SetDescription(__x("Display some mathematical images.

You are running under: Perl {perlver}, wxPerl {wxperlver}, Wx {wxver}",
                            perlver    => sprintf('%vd', $^V),
                            wxver      => Wx::wxVERSION_STRING(),
                            wxperlver  => Wx->VERSION));

  $info->SetCopyright(__x("Copyright (C) 2010, 2011 Kevin Ryde

Math-Image is Free Software, distributed under the terms of the GNU General
Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.  Click on the
License button below for the full text.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more.
"));

  # the same as COPYING in the sources
  require Software::License::GPL_3;
  my $sl = Software::License::GPL_3->new({ holder => 'Kevin Ryde' });
  $info->SetLicense ($sl->license);

  Wx::AboutBox($info);
}

sub popup_program_pod {
  my ($self) = @_;
  $self->popup_pod('math-image');
}
sub popup_path_pod {
  my ($self) = @_;
  my $draw = $self->{'draw'};
  if (my $path = $draw->{'path'}) {
    if (my $module = App::MathImage::Generator->path_choice_to_class ($path)) {
      $self->popup_pod($module);
    }
  }
}
sub popup_values_pod {
  my ($self) = @_;
  my $draw = $self->{'draw'};
  if (my $values = $draw->{'values'}) {
    if ((my $module = App::MathImage::Generator->values_choice_to_class($values))) {
      $self->popup_pod($module);
    }
  }
}
sub popup_pod {
  my ($self, $module) = @_;
  ### popup_pod(): $module
  if (eval { require Wx::Perl::PodBrowser }) {
    my $browser = Wx::Perl::PodBrowser->new;
    $browser->Show;
    $browser->goto_pod (module => $module);
  } else {
    Wx::MessageBox (__('Wx::Perl::PodBrowser not available')."\n\n$@",
                    __('Math-Image: Error'),
                    Wx::wxICON_ERROR(),
                    $self);
  }
}


#------------------------------------------------------------------------------
# status

sub mouse_motion {
  my ($self, $event) = @_;
  ### Wx-Main mouse_motion() ...
  my $message = '';
  if ($event) {
    if (my $gen_object = $self->{'draw'}->gen_object_maybe) {
      ### xy: $event->GetX.','.$event->GetY
      $message = $gen_object->xy_message ($event->GetX, $event->GetY);
      ### $message
    }
  }
  $self->set_position_status ($message);
}
sub set_position_status {
  my ($self, $message) = @_;
  if ($self->{'position_status'} ne $message) {
    $self->SetStatusText ($message);
    $self->{'position_status'} = $message;
  }
}

#------------------------------------------------------------------------------
# command line

sub command_line {
  my ($class, $mathimage) = @_;

  my $app = Wx::SimpleApp->new;
  $app->SetAppName(__('Math Image'));

  my $gen_options = $mathimage->{'gen_options'};
  my $width = delete $gen_options->{'width'};
  my $height = delete $gen_options->{'height'};

  my $self = $class->new ("Math-Image");

  my $draw = $self->{'draw'};
  {
    ### foreground: $gen_options->{'foreground'}
    my $wxc = Wx::Colour->new (delete $gen_options->{'foreground'});
    $draw->SetForegroundColour($wxc);
  }
  { my $wxc = Wx::Colour->new (delete $gen_options->{'background'});
    $draw->SetBackgroundColour($wxc);
  }

  ### command_line draw: $gen_options
  %$draw = (%$draw,
            %$gen_options);
  $draw->redraw;
  _controls_from_draw ($self);

  if (defined $width) {
    #   require Wx::Perl::Units;
    #   Wx::Perl::Units::SetInitialSizeWithSubsizes
    #       ($self, [ $draw, $width, $height ]);

    $draw->SetSize ($width, $height);
    my $size = $self->GetBestSize;
    $draw->SetSize (-1,-1);

    ### $width
    ### $height
    ### best width: $size->GetWidth
    ### best height: $size->GetHeight
    $self->SetSize ($size);

  } else {
    my $screen_size = Wx::GetDisplaySize();
    $self->SetSize (Wx::Size->new ($screen_size->GetWidth * 0.8,
                                   $screen_size->GetHeight * 0.8));
  }

  if (delete $mathimage->{'gui_options'}->{'fullscreen'}) {
    $self->ShowFullScreen(1, FULLSCREEN_HIDE_BITS)
  } else {
    $self->Show;
  }
  $app->MainLoop;
  return 0;

  # my $path_parameters = delete $gen_options->{'path_parameters'};
  # my $values_parameters = delete $gen_options->{'values_parameters'};
  # ### draw set gen_options: keys %$gen_options
  # foreach my $key (keys %$gen_options) {
  #   $draw->set ($key, $gen_options->{$key});
  # }
  # $draw->set (path_parameters => $path_parameters);
  # $draw->set (values_parameters => $values_parameters);
  # ### draw values now: $draw->get('values')
  # ### values_parameters: $draw->get('values_parameters')
  # ### path: $draw->get('path')
  # ### path_parameters: $draw->get('path_parameters')
}

1;
