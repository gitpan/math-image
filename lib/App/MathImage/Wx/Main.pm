# Copyright 2011 Kevin Ryde

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
#use Devel::Comments;

our $VERSION = 77;

sub new {
  my ($class, $label) = @_;
  my $self = $class->SUPER::new (undef,
                                 -1,
                                 $label);

  # load an icon and set it as frame icon
  $self->SetIcon (Wx::GetWxPerlIcon());

  my $menubar = Wx::MenuBar->new;
  $self->SetMenuBar ($menubar);

  my $id = 0;
  {
    my $menu = Wx::Menu->new;
    $menubar->Append ($menu, "&File");

    $menu->Append(Wx::wxID_EXIT(), '', ''); # "Exit this program");
    EVT_MENU ($self, Wx::wxID_EXIT(), 'quit');
  }
  {
    my $menu = Wx::Menu->new;
    $menubar->Append ($menu, "&Tools");
    {
      my $item = $self->{'menuitem_fullscreen'} =
        $menu->AppendCheckItem (++$id, "&Fullscreen\tCtrl-F", "");
      EVT_MENU ($self, $item, '_menu_fullscreen');
    }
  }
  {
    my $menu = Wx::Menu->new;
    $menubar->Append ($menu, "&Help");

    $menu->Append (Wx::wxID_ABOUT(), '', ''); # "Show about dialog");
    EVT_MENU ($self, Wx::wxID_ABOUT(), 'popup_about');
  }

  {
    my $toolbar = $self->CreateToolBar;

    # my $bitmap = Wx::Bitmap->new (10,10);
    # $toolbar->AddTool(++$id,
    #                   __('&Randomize'),
    #                   $bitmap, # Wx::wxNullBitmap(),
    #                   "Random path, values, etc",
    #                   Wx::wxITEM_NORMAL());
    # EVT_MENU ($self, $id, 'randomize');

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
        = App::MathImage::Wx::Params->new (toolbar => $toolbar,
                                           after_item => $choice);
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
         __('The values for where to place values in the plane.'));
      Wx::Event::EVT_CHOICE ($self, $choice, 'values_update');

      my $values_params = $self->{'values_params'}
        = App::MathImage::Wx::Params->new (toolbar => $toolbar,
                                           after_item => $choice);
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
      my $choice = $self->{'figure_choice'}
        = Wx::Choice->new ($toolbar,
                           Wx::wxID_ANY(),
                           Wx::wxDefaultPosition(),
                           Wx::wxDefaultSize(),
                           [App::MathImage::Generator->figure_choices]);
      $toolbar->AddControl($choice);
      $toolbar->SetToolShortHelp
        ($choice->GetId,
         __('The figure to draw at each position.'));
      Wx::Event::EVT_CHOICE ($self, $choice, 'figure_update');
    }
  }

  $self->CreateStatusBar;

  my $draw = $self->{'draw'} = App::MathImage::Wx::Drawing->new ($self);
  path_update($self); # initial
  values_update($self); # initial
  _update_controls ($self);

  return $self;
}

sub _menu_fullscreen {
  my ($self, $event) = @_;
  ### Main _menu_fullscreen() ...
  $self->ShowFullScreen ($self->{'menuitem_fullscreen'}->IsChecked,
                         Wx::wxFULLSCREEN_ALL());

  # } else {
  #   ### Show ...
  #   $self->Show;
  # }
}

sub randomize {
  my ($self, $event) = @_;
  ### Main randomize() ...

  my $draw = $self->{'draw'};
  my %options = App::MathImage::Generator->random_options;
  @{$draw}{keys %options} = values %options;
  _update_controls ($self);
  delete $draw->{'bitmap'};
  $draw->Refresh;
}
sub scale_update {
  my ($self, $event) = @_;
  ### Main scale_update() ...
  my $draw = $self->{'draw'};
  $draw->{'scale'} = $self->{'scale_spin'}->GetValue;
  delete $draw->{'bitmap'};
  $draw->Refresh;
}
sub figure_update {
  my ($self, $event) = @_;
  ### Main figure_update() ...
  my $draw = $self->{'draw'};
  $draw->{'figure'} = $self->{'figure_choice'}->GetStringSelection;
  delete $draw->{'bitmap'};
  $draw->Refresh;
}
sub path_update {
  my ($self) = @_;  # ($self, $event)
  ### Main path_update(): "$self"
  my $draw = $self->{'draw'};
  my $path = $draw->{'path'} = $self->{'path_choice'}->GetStringSelection;
  $self->{'path_params'}->SetParameterInfoArray
    (App::MathImage::Generator->path_class($path)->parameter_info_array);
  delete $draw->{'bitmap'};
  $draw->Refresh;
}
sub values_update {
  my ($self, $event) = @_;
  ### Main values_update() ...
  my $draw = $self->{'draw'};
  my $values = $draw->{'values'} = $self->{'values_choice'}->GetStringSelection;
  $self->{'values_params'}->SetParameterInfoArray
    (App::MathImage::Generator->values_class($values)->parameter_info_array);
  delete $draw->{'bitmap'};
  $draw->Refresh;
}
sub _update_controls {
  my ($self) = @_;
  my $draw = $self->{'draw'};
  $self->{'path_choice'}->SetStringSelection ($draw->{'path'});
  $self->{'values_choice'}->SetStringSelection ($draw->{'values'});
  $self->{'scale_spin'}->SetValue ($draw->{'scale'});
  $self->{'figure_choice'}->SetStringSelection ($draw->{'figure'});
}

sub quit {
  my ($self, $event) = @_;
  $self->Close (1);
}

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

You are running under: Perl {perlver}, Gtk-Perl {wxperlver}, Gtk {wxver}",
                            perlver    => sprintf('%vd', $^V),
                            wxver      => Wx::wxVERSION_STRING,
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

sub mouse_motion {
  my ($self, $event) = @_;
  ### Main _do_motion() ...

  my $statusbar = $self->GetStatusBar;
  $statusbar->SetStatusText ('');

  my $draw = $self->{'draw'};
  my ($x, $y, $n) = $draw->pointer_xy_to_image_xyn ($event->GetX, $event->GetY);
  my $message = '';
  if (defined $x) {
    $message = sprintf ("x=%.*f, y=%.*f",
                        (int($x)==$x ? 0 : 2), $x,
                        (int($y)==$y ? 0 : 2), $y);
    if (defined $n) {
      $message .= "   N=$n";
      if ((my $values = $draw->{'values'})
          && (my $values_obj = $draw->gen_object->values_object)) {
        my $vstr = '';
        my $radix;
        if ($values_obj->can('ith')
            && (($radix = $values_obj->characteristic('digits'))
                || $values_obj->characteristic('count')
                || $values_obj->characteristic('modulus'))) {
          my $value = $values_obj->ith($n);
          $vstr = " value=$value";
          if ($value &&
              $values_obj->isa('App::MathImage::NumSeq::RepdigitBase')) {
            $radix = $value;
          }
        }
        my $values_parameters;
        if (($radix && $radix != 10)
            || ($values ne 'Emirps'
                && ($values_parameters = $draw->{'values_parameters'})
                && $draw->gen_object->values_class->parameter_info_hash->{'radix'}
                && ($radix = $values_parameters->{'radix'}))) {
          my $str = _my_cnv($n,$radix);
          $message .= " ($str in base $radix)";
        }
        $message .= $vstr;
      }
    }
  }

  ### $message
  $statusbar->SetStatusText ($message);
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

  if (defined $width) {
    #   require Wx::Perl::Units;
    #   Wx::Perl::Units::SetInitialSizeWithSubsizes
    #       ($self, [ $draw, $width, $height ]);

    $draw->SetSize (Wx::Size->new ($width, $height));
    my $size = $self->GetBestSize;
    ### $width
    ### $height
    ### best width: $size->GetWidth
    ### best height: $size->GetHeight
    $self->SetInitialSize ($size);
    $draw->SetSize (-1,-1);
  } else {
    my $screen_size = Wx::GetDisplaySize();
    $self->SetInitialSize (Wx::Size->new ($screen_size->GetWidth * 0.8,
                                          $screen_size->GetHeight * 0.8));
  }

  if (delete $mathimage->{'gui_options'}->{'fullscreen'}) {
    $self->{'menuitem_fullscreen'}->Check(1);
  } else {
    $self->Show;
  }
  $app->MainLoop;
  return 0;

  # ### draw set: $gen_options
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
