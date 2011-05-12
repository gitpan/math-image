# Copyright 2010, 2011 Kevin Ryde

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


package App::MathImage::Gtk2::Params;
use 5.008;
use strict;
use warnings;
use List::Util;
use POSIX ();
use Module::Load;
use Glib::Ex::ObjectBits 'set_property_maybe';
use Glib::Ex::ConnectProperties;
use Gtk2::Ex::ToolbarBits;
use Gtk2::Ex::MenuBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 56;

use Glib::Object::Subclass
  'Glib::Object',
  properties => [ Glib::ParamSpec->scalar
                  ('values',
                   'Values',
                   'Blurb.',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->scalar
                  ('parameter-list',
                   'Parameter List',
                   'Blurb.',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('toolbar',
                   'Toolbar',
                   'Blurb.',
                   'Gtk2::Toolbar',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('after-toolitem',
                   'After Toolitem',
                   'Blurb.',
                   'Gtk2::ToolItem',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->{'toolitems_hash'} = {};
  $self->{'parameter_list'} = [];
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  ### Params GET_PROPERTY: $pname

  if ($pname eq 'values') {
    my $toolitems_hash = $self->{'toolitems_hash'};
    # ### $toolitems_hash
    ### parameter_list: $self->{'parameter_list'}
    my %ret;
    foreach my $pinfo (@{$self->{'parameter_list'} || []}) {
      if (_pinfo_when($self,$pinfo)
          && (my $toolitem = _pinfo_to_toolitem ($self, $pinfo))) {
        ### $pinfo
        $ret{$pinfo->{'name'}} = $toolitem->get('value');
      }
    }
    ### Params: %ret
    return \%ret;

  } else {
    ### get: $self->{$pname}
    return $self->{$pname};
  }
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### Params SET_PROPERTY: $pname, $newval
  $self->{$pname} = $newval;

  if ($pname eq 'parameter_list') {
    my $toolbar = $self->{'toolbar'};
    my $toolitems_hash = $self->{'toolitems_hash'};
    my %hide = %$toolitems_hash;
    my $after = $self->{'after_toolitem'};

    foreach my $pinfo (@$newval) {
      ### $pinfo
      my $name = $pinfo->{'name'};
      my $key = $pinfo->{'share_key'} || $name;

      my $toolitem = $toolitems_hash->{$key};
      if (defined $toolitem) {
        delete $hide{$key};
      } else {
        ### new toolitem
        ### $name
        ### type: $pinfo->{'type'}
        my $ptype = $pinfo->{'type'};
        my $display = ($pinfo->{'display'} || $name);
        my $tooltip_extra;
        Scalar::Util::weaken (my $weak_self = $self);

        if ($ptype eq 'boolean') {
          require App::MathImage::Gtk2::Params::Boolean;
          $toolitem = App::MathImage::Gtk2::Params::Boolean->new
            (label  => $display,
             active => $pinfo->{'default'});

        } elsif ($ptype eq 'enum') {
          require App::MathImage::Gtk2::Params::Enum;
          $toolitem = App::MathImage::Gtk2::Params::Enum->new;

        } elsif ($ptype eq 'integer') {
          require App::MathImage::Gtk2::Params::Integer;
          $toolitem = App::MathImage::Gtk2::Params::Integer->new;

        } elsif ($ptype eq 'float') {
          my $class = 'App::MathImage::Gtk2::Params::Float';
          if (($pinfo->{'type_hint'}||'') eq 'expression') {
            $class .= 'Expression';
          }
          Module::Load::load ($class);
          $toolitem = $class->new;

        } elsif ($ptype eq 'filename') {
          require App::MathImage::Gtk2::Params::Filename;
          $toolitem = App::MathImage::Gtk2::Params::Filename->new;

        } else {
          require App::MathImage::Gtk2::Params::String;
          $toolitem = App::MathImage::Gtk2::Params::String->new;
        }

        $toolitem->signal_connect
          ('notify::value' => \&_do_toolitem_changed, \$weak_self);

        set_property_maybe ($toolitem, # tooltip-text new in 2.12
                            tooltip_text => join("\n\n", grep {defined} $pinfo->{'description'}, $tooltip_extra));
        $toolitems_hash->{$key} = $toolitem;
        $toolitem->show_all;
        $toolbar->insert ($toolitem, -1);
      }

      $toolitem->set (parameter_info => $pinfo);
      Gtk2::Ex::ToolbarBits::move_item_after ($toolbar, $toolitem, $after);
      $after = $toolitem;
    }

    foreach my $toolitem (values %hide) {
      $toolitem->hide;
    }
    _update_visible ($self);
    $self->notify('values');
  }
}

sub _do_toolitem_changed {
  my ($toolitem) = @_;
  my $ref_weak_self = $_[-1];
  my $self = $$ref_weak_self || return;
  ### Params notify values
  $self->notify ('values');
  _update_visible ($self);
}

sub _update_visible {
  my ($self) = @_;
  ### _update_visible
  my $toolitems_hash = $self->{'toolitems_hash'};
  foreach my $pinfo (@{$self->{'parameter_list'}}) {
    ### name: $pinfo->{'name'}
    if (my $toolitem = _pinfo_to_toolitem($self,$pinfo)) {
      $toolitem->set (visible => _pinfo_when($self,$pinfo));
    }
  }
}

sub _pinfo_when {
  my ($self, $pinfo) = @_;
  if (my $when_name = $pinfo->{'when_name'}) {
    ### $when_name
    if (my $when_pinfo = List::Util::first {$_->{'name'} eq $when_name} @{$self->{'parameter_list'}}) {
      if (my $when_toolitem = _pinfo_to_toolitem($self,$when_pinfo)) {
        my $got_value = $when_toolitem->get('value');
        ### $got_value
        return (defined $got_value
                && $got_value eq $pinfo->{'when_value'});
      }
    }
  }
  return 1;
}

sub _pinfo_to_toolitem {
  my ($self, $pinfo) = @_;
  return $self->{'toolitems_hash'}->{$pinfo->{'share_key'} || $pinfo->{'name'}};
}


1;
__END__
