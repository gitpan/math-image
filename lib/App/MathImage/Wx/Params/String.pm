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


# ENHANCE-ME:
# want ComboBox when choices, or TextCtrl when not, maybe
# or flags wxCB_DROPDOWN or wxCB_READONLY for when choices-only

package App::MathImage::Wx::Params::String;
use 5.004;
use strict;
use Carp;
use Wx;

use base 'Wx::ComboBox';
our $VERSION = 104;

# uncomment this to run the ### lines
#use Smart::Comments;


sub new {
  my ($class, $parent, $info) = @_;
  ### Wx-Params-String new(): "$parent"

  # my $display = ($newval->{'display'} || $newval->{'name'});
  my $choices = $info->{'choices'};

  my $value = $info->{'default'};
  if (! defined $value) { $value = '' }

  my $width_chars = $info->{'width'} || 5;
  # my $font = $self->GetFont;
  # my $font_points = $font->GetPointSize;
  # my $font_mm = $font_points * (1/72 * 25.4);
  my $em_pixels = 10;
  my $width_pixels = $width_chars * $em_pixels + 15;

  my $self = $class->SUPER::new ($parent,
                                 Wx::wxID_ANY(),   # id
                                 $value,           # initial value
                                 Wx::wxDefaultPosition(),
                                 Wx::Size->new ($width_pixels, -1),
                                 $choices || [],
                                 Wx::wxTE_PROCESS_ENTER());  # style

  my $type_hint = $info->{'type_hint'} || '';
  $self->{'oeis_anum'} = ($type_hint eq 'oeis_anum');
  $self->{'scroll_rotation'} = 0;
  $self->{'prev'} = $self->GetValue;

  # Wx::Event::EVT_TEXT_PASTE ($self, $self, 'OnTextUpdated');
  Wx::Event::EVT_TEXT_ENTER ($self, $self, 'OnTextEnter');
  Wx::Event::EVT_COMBOBOX ($self, $self, 'OnTextEnter');
  Wx::Event::EVT_MOUSEWHEEL ($self, 'OnMouseWheel');
  Wx::Event::EVT_TEXT ($self, $self, 'OnTextUpdated');
  return $self;
}

sub SetParameterInfo {
  my ($self, $info) = @_;
  $self->{'parameter_info'} = $info;

    # unless ($entry) {
    #   my $entry_class = 'Wx::Entry';
    #   my $type_hint = ($newval->{'type_hint'} || '');
    #   if ($type_hint eq 'oeis_anum') {
    #     require App::MathImage::Wx::OeisEntry;
    #     $entry_class = 'App::MathImage::Wx::OeisEntry';
    #   }
    #   if ($type_hint eq 'fraction') {
    #     require App::MathImage::Wx::FractionEntry;
    #     $entry_class = 'App::MathImage::Wx::FractionEntry';
    #   }
    #   $entry = $entry_class->new;
    #   if (exists $self->{'parameter_value_set'}) {
    #     $entry->set (text => $self->{'parameter_value_set'});
    #     $self->{'parameter_value_set'} = 1;
    #   }
    #   Scalar::Util::weaken (my $weak_self = $self);
    #   $entry->signal_connect (activate => \&_do_entry_activate, \$weak_self);
    #   $entry->show;
    #   $self->add ($entry);
    # }
}

sub SetValue {
  my ($self, $value) = @_;
  if (! defined $value) { $value = ''; }
  my $n = $self->FindString ($value);
  if ($n == Wx::wxNOT_FOUND()) {
    $self->SUPER::SetValue ($value);
  } else {
    $self->SUPER::SetSelection ($n);
  }
}

sub OnTextEnter {
  my ($self, $event) = @_;
  ### Wx-Params-String OnTextEnter()...

  # don't want to refresh on every idleness
  # Wx::Event::EVT_UPDATE_UI ($self, $self, \&_update_tooltip);
  _update_tooltip($self);

  if (my $callback = $self->{'callback'}) {
    &$callback($self);
  }
}

# ENHANCE-ME: how to catch paste event before text update ?
sub OnTextUpdated {
  my ($self, $event) = @_;
  ### Wx-Params-String OnTextUpdated(): $event
  ### GetString: $event->GetString

  my $prev = $self->{'prev'};
  my $str = $self->GetValue;
  my $addlen = length($str) - length($prev);
  my $pos = $self->GetInsertionPoint;

  foreach my $anumlen (6, 7) {
    if ($addlen == $anumlen && $pos >= $anumlen) {
      my $anum = substr ($str, $pos-$anumlen, $anumlen);
      if ($anum =~ /^A\d+$/) {
        $self->SetValue($anum);
        $self->OnTextEnter;
        return;
      }
    }
  }
  $self->{'prev'} = $self->GetValue;
}


#------------------------------------------------------------------------------

sub OnMouseWheel {
  my ($self, $event) = @_;
  ### OnMouseWheel() ...
  ### $event

  if ($self->{'oeis_anum'}) {
    my $rotation = $self->{'scroll_rotation'};
    $rotation += $event->GetWheelRotation;
    my $delta = $event->GetWheelDelta;
    ### $rotation
    ### $delta

    my $anum
      = my $orig_anum
        = $self->GetValue;
    for (;;) {
      ### $anum

      my $next_anum;
      if ($rotation >= $delta) {
        ### after ...
        $rotation -= $delta;
        $next_anum = Math::NumSeq::OEIS::Catalogue->anum_after($anum);
        if (! defined $next_anum) {
          $anum = Math::NumSeq::OEIS::Catalogue->anum_last;
          $rotation %= $delta;
          last;
        }

      } elsif ($rotation <= -1) {
        ### before ...
        $rotation += $delta;
        $next_anum = Math::NumSeq::OEIS::Catalogue->anum_before($anum);
        if (! defined $next_anum) {
          $anum = Math::NumSeq::OEIS::Catalogue->anum_first;
          $rotation %= $delta;
          if ($rotation > 0) { $rotation -= $delta; }
          last;
        }

      } else {
        last;
      }
      $anum = $next_anum;
    }

    if ($anum ne $orig_anum) {
      $self->SetValue ($anum);
      $self->OnTextEnter;
      # $self->Command (Wx::CommandEvent->new(Wx::wxEVT_COMMAND_TEXT_ENTER()));
    }
    $self->{'scroll_rotation'} = $rotation;
    ### rotation remaining: $rotation

  } else {
    $event->Skip(1); # propagate to other processing
  }
}

sub _update_tooltip {
  my ($self) = @_;
  ### Wx-Main values_update_tooltip() ...

  if ($self->{'oeis_anum'}) {
    my $anum = $self->GetValue;
    my $str;
    require Math::NumSeq::OEIS::Catalogue;
    if (my $info = Math::NumSeq::OEIS::Catalogue->anum_to_info($anum)) {
      my $class = $info->{'class'};
      if ($class eq 'Math::NumSeq::Expression') {
        $str = "Expression\n"
          . ({@{$info->{'parameters'}}})->{'expression'};
      } else {
        if ($class eq 'Math::NumSeq::OEIS::File') {
          $str = "File";
        } else {
          $str = $class;
          $str =~ s/^Math::NumSeq:://;
        }
        eval {
          # description() from file or module, if possible
          $str .= ("\n"
                   . Math::NumSeq::OEIS->new(anum=>$anum)->description);
        };
      }

      # if (my $parameters = $info->{'parameters'}) {
      #   my @eqs;
      #   for (my $i = 0; $i < @$parameters; $i+=2) {
      #     push @eqs, "$parameters->[$i]=$parameters->[$i+1]";
      #   }
      #   $str .= "\n" . join(', ', @eqs);
      # }
    }
    ### $str

    my $toolbar = $self->GetParent;
    ### parent: ref $toolbar
    if ($toolbar->isa('Wx::ToolBar')) {
      $toolbar->SetToolShortHelp ($self->GetId, $str);
    }
  }
}

1;
__END__














# package App::MathImage::Wx::Params::String;
# use 5.004;
# use strict;
# use Carp;
# use Wx;
# 
# use base qw(Wx::TextCtrl);
# our $VERSION = 98;
# 
# # uncomment this to run the ### lines
# use Smart::Comments;
# 
# 
# sub new {
#   my ($class, $parent, $info) = @_;
#   ### Wx-Params-String new(): "$parent"
# 
#   # my $display = ($newval->{'display'} || $newval->{'name'});
#   my $self = $class->SUPER::new ($parent,
#                                  Wx::wxID_ANY(),       # id
#                                  $info->{'default'} || '', # initial value
#                                  Wx::wxDefaultPosition(),
#                                  Wx::Size->new (10*($info->{'width'} || 5),
#                                                 -1),
#                                  Wx::wxTE_PROCESS_ENTER());  # style
# 
#   Wx::Event::EVT_TEXT_ENTER ($self, $self, 'OnTextEnter');
#   return $self;
# }
# 
# sub SetParameterInfo {
#   my ($self, $info) = @_;
#   $self->{'parameter_info'} = $info;
# 
#     # unless ($entry) {
#     #   my $entry_class = 'Wx::Entry';
#     #   my $type_hint = ($newval->{'type_hint'} || '');
#     #   if ($type_hint eq 'oeis_anum') {
#     #     require App::MathImage::Wx::OeisEntry;
#     #     $entry_class = 'App::MathImage::Wx::OeisEntry';
#     #   }
#     #   if ($type_hint eq 'fraction') {
#     #     require App::MathImage::Wx::FractionEntry;
#     #     $entry_class = 'App::MathImage::Wx::FractionEntry';
#     #   }
#     #   $entry = $entry_class->new;
#     #   if (exists $self->{'parameter_value_set'}) {
#     #     $entry->set (text => $self->{'parameter_value_set'});
#     #     $self->{'parameter_value_set'} = 1;
#     #   }
#     #   Scalar::Util::weaken (my $weak_self = $self);
#     #   $entry->signal_connect (activate => \&_do_entry_activate, \$weak_self);
#     #   $entry->show;
#     #   $self->add ($entry);
#     # }
# }
# 
# sub SetValue {
#   my ($self, $value) = @_;
#   if (! defined $value) { $value = ''; }
#   $self->SUPER::SetValue ($value);
# }
# 
# sub OnTextEnter {
#   my ($self, $event) = @_;
#   #   ### Params-String OnActivate()...
#   #   my $self = $$ref_weak_self || return;
#   #   ### parameter-value now: $self->get('parameter-value')
#   #   $self->notify ('parameter-value');
# 
#   if (my $callback = $self->{'callback'}) {
#     &$callback($self);
#   }
# }

