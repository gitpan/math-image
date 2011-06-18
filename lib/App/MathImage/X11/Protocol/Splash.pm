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


# rootwin for ewmh virtual root?

package App::MathImage::X11::Protocol::Splash;
use 5.004;
use strict;
use Carp;
use List::Util 'max';  # 5.6 ?
use X11::Protocol;
use X11::Protocol::WM;
use X11::AtomConstants;

use vars '$VERSION';
$VERSION = 60;

# uncomment this to run the ### lines
#use Smart::Comments;

BEGIN {
  eval 'utf8->can("is_utf8") && *is_utf8 = \&utf8::is_utf8'   # 5.8.1
    || eval 'use Encode "is_utf8"; 1'                         # 5.8.0
      || eval 'sub is_utf8 () { 0 }; 1'                       # 5.6 fallback
        || die 'Oops, cannot create is_utf8() subr: ',$@;
}
### \&is_utf8

# /usr/share/doc/xorg-docs/specs/ICCCM/icccm.txt.gz

sub new {
  my ($class, %self) = @_;
  return bless \%self, $class;
}

sub DESTROY {
  my ($self) = @_;
  if (my $win = $self->{'window'}) {
    $self->{'X'}->DestroyWindow ($win);
  }
}

sub popup {
  my ($self) = @_;
  my $X = $self->{'X'};
  $X->MapWindow ($self->create_window);
  $X->ClearArea ($self->{'window'}, 0,0,0,0);
  $X->flush;
}

sub popdown {
  my ($self) = @_;
  if (my $win = $self->{'window'}) {
    my $X = $self->{'X'};
    $X->UnmapWindow ($win);
    $X->flush;
  }
}

sub create_window {
  my ($self) = @_;
  if (! $self->{'window'}) {
    my $X = $self->{'X'};
    my $pixmap = $self->{'pixmap'};
    my $width = $self->{'width'};
    my $height = $self->{'height'};
    if (! defined $width || ! defined $height) {
      my %geom = $X->GetGeometry($pixmap);
      $width = $self->{'width'} =  $geom{'width'};
      $height = $self->{'height'} = $geom{'height'};
    }
    my $x = int (max (0, $X->{'width_in_pixels'} - $width) / 2); #  + 100
    my $y = int (max (0, $X->{'height_in_pixels'} - $height) / 2);

    ### sync: $X->QueryPointer($X->{'root'})
    my $window = $X->new_rsrc;
    $X->CreateWindow ($window,
                      $X->{'root'},     # parent
                      'InputOutput',    # class
                      0,                # depth, from parent
                      'CopyFromParent', # visual
                      $x,$y,
                      $width,$height,
                      0,                # border
                      background_pixmap => $pixmap,
                      # background_pixel  => 0x00FFFF,
                      override_redirect => 1,
                      # save_under        => 1,
                      # backing_store     => 'Always',
                      # bit_gravity       => 'Static',
                      # event_mask        =>
                      # $X->pack_event_mask('Exposure',
                      #                     'ColormapChange',
                      #                     'VisibilityChange',),
                     );
    # $X->ChangeWindowAttributes ($window,
    #                            );
    if ($window == 0x1600002) {
    }
    ### sync: $X->QueryPointer($X->{'root'})
    $self->{'window'} = $window;

    _set_wm_name ($X, $window, "Splash");
    _set_net_wm_name ($X, $window, "Splash");
    if (my $transient_for = $self->{'transient_for'}) {
      X11::Protocol::WM::set_wm_transient_for
          ($X, $window, $transient_for);
    }
    X11::Protocol::WM::set_wm_hints
        ($X, $window,
         input => 0,
         window_group => $self->{'window_group'});
    X11::Protocol::WM::set_net_wm_window_type ($X, $window, 'SPLASH');
  }
  return $self->{'window'};
}


#------------------------------------------------------------------------------
# _NET_WM_ALLOWED_ACTIONS

# Return 'CLOSE' or atom integer if unrecognised
sub _get_net_wm_allowed_actions {
  my ($X, $window) = @_;
  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($window,
                       $X->atom('_NET_WM_ALLOWED_ACTIONS'), # property
                       X11::AtomConstants::ATOM,            # type
                       0,             # offset
                       999,           # length, of CARD32
                       0);            # no delete
  if ($format == 32) {
    # ENHANCE-ME: atom fetches in one round trip
    return map {_net_wm_allowed_action_interp($_)} unpack('L*',$value);
  } else {
    return;
  }
}
sub _net_wm_allowed_action_interp {
  my ($X, $atom) = @_;
  # FIXME: robust_req() in case garbage atom
  my $name = $X->atom_name ($atom);
  if ($name =~ s/^_NET_WM_ALLOWED_ACTION_//) {
    return $name;
  } else {
    return $atom;
  }
}


# Set by the window manager.
#
# =item C<_set_net_wm_allowed_actions ($X, $window, $action...)>
#
#
sub _set_net_wm_allowed_actions {
  my $X = shift;
  my $window = shift;
  my $prop = $X->atom('_NET_WM_ALLOWED_ACTIONS');
  if (@_) {
    $X->ChangeProperty($window,
                       $prop,                    # property
                       X11::AtomConstants::ATOM, # type
                       32,                       # format
                       'Replace',
                       pack 'L*', map {_net_wm_allowed_action_to_atom($_)} @_);
  } else {
    $X->DeleteProperty ($window, $prop);
  }
}

sub _net_wm_allowed_action_to_atom {
  my ($X, $action) = @_;
  if (! defined $action || $action =~ /^\d+$/) {
    return $action;
  } else {
    return $X->atom ("_NET_WM_ACTION_$action");
  }
}


#------------------------------------------------------------------------------
# WM_HINTS

{
  my $format = 'LLLLLllLL';

  sub _get_wm_hints {
    my ($X, $window) = @_;
    my ($value, $type, $format, $bytes_after)
      = $X->GetProperty ($window,
                         X11::AtomConstants::WM_HINTS, # prop name
                         X11::AtomConstants::WM_HINTS, # type
                         0,             # offset
                         9,             # length($format), of CARD32
                         0);            # no delete
    if ($format == 32) {
      return _unpack_wm_hints ($X, $value);
    } else {
      return;
    }
  }

  # X11R2 Xlib had a bug were XSetWMHints() set a WM_HINTS property to only
  # 8 CARD32s, chopping off the window_group field.  In Xatomtype.h
  # NumPropWMHintsElements was 8 instead of 9.  Ignore any window_group bit
  # in the flags in that case, and don't return a window_group field.
  # (X11R2 source available at http://ftp.x.org/pub/X11R2/X.V11R2.tar.gz)
  #
  my @keys = ('input',
              'initial_state',
              'icon_pixmap',
              'icon_window',
              'icon_x',
              'icon_y',
              'icon_mask',
              'window_group',
              # 'message_hint',  # in the code, obsolete ...
              # 'urgency',       # in the code
             );
  sub _unpack_wm_hints {
    my ($X, $bytes) = @_;
    my ($flags, @values) = unpack ($format, $bytes);
    my $bit = 1;
    my @ret;
    foreach my $i (0 .. $#keys) {
      my $value = $values[$i];
      if (! defined $value) {
        next;
      }
      if ($flags & $bit) {
        my $key = $keys[$i];
        if ($key eq 'initial_state') {
          $value = _wmstate_interp($X, $value);
        }
        push @ret, $key, $value;
      }
      if ($i != 4) {
        $bit <<= 1;
      }
    }
    if ($flags & 128) {
      push @ret, message_hint => 1;
    }
    if ($flags & 256) {
      push @ret, urgency => 1;
    }
    return @ret;
  }
}

#------------------------------------------------------------------------------
# _NET_WM_STATE

# =item C<($state1, $state2, ..) = _get_net_wm_state ($X, $window)>
#
# Return the C<_NET_WM_STATE> property from C<$window>.
#
sub _get_net_wm_state_names {
  my ($X, $window) = @_;
  return atom_names($X, _get_net_wm_state_atoms($X,$window));
}
sub _get_net_wm_state_atomhash {
  my ($X, $window) = @_;
  return { map {$_=>1} _get_net_wm_state_atoms($X,$window) };
}
sub _get_net_wm_state_atoms {
  my ($X, $window) = @_;
  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($window,
                       $X->atom('_NET_WM_STATE'),     # property
                       X11::AtomConstants::CARDINAL,  # type
                       0,    # offset
                       999,  # length
                       0);   # delete
  if ($format == 32) {
    return unpack('L*', $value);
  } else {
    return;
  }
}
sub _net_wm_state_atom_interp {
  my ($X, $atom) = @_;
  if ($X->{'do_interp'}) {
    my $str = $X->atom_name ($atom);
    if ($str =~ s/^_NET_WM_STATE_//) {
      return $str;
    }
  }
  return $atom;
}

#------------------------------------------------------------------------------
# WM_CLIENT_MACHINE

# =item C<_set_wm_client_machine_from_syshostname ($X, $window)>
#
# Set the C<WM_CLIENT_MACHINE> property on C<$window> using the
# C<Sys::Hostname> module.
#
# Currently if that module can't determine a hostname by its various gambits
# then the property is deleted.  Should it leave it unchanged, or return a
# flag to say if set?
#
# Some of the C<Sys::Hostname> cases can end up returning "localhost".  It's
# presumed this would be when there's no networking beyond the local host,
# and that in this case clients are always on the same machine as the server
# are on the same machine so "localhost" is a good enough name.
#
sub _set_wm_client_machine_from_syshostname {
  my ($X, $window) = @_;
  require Sys::Hostname;
  _set_wm_client_machine ($X, $window, eval { Sys::Hostname::hostname() });
}

# =item C<_set_wm_client_machine ($X, $window, $hostname)>
#
# Set the C<WM_CLIENT_MACHINE> property on C<$window> to C<$hostname> (a
# string).  C<$hostname> should be the name of the client machine as seen
# from the server.  If C<$hostname> is C<undef> then the property is
# deleted.
#
# Usually a machine name is ASCII-only, but in Perl 5.8 up if C<$hostname is
# a wide-char string it will be encoded to "STRING" (latin-1) or
# "COMPOUND_TEXT" as necessary.
#
sub _set_wm_client_machine {
  my ($X, $window, $hostname) = @_;
  _set_text_property ($X, $window,
                      X11::AtomConstants::WM_CLIENT_MACHINE, $hostname);
}


#------------------------------------------------------------------------------
# _NET_WM_PID

# =item C<_set_net_wm_pid_from_self ($X, $window)>
#
# Set the C<_NET_WM_PID> property on C<$window> to the process ID of the
# current process, ie. Perl's C<$$> variable (see L<perlvar>).  A window
# manager or similar can use this to forcibly kill an unresponsive client
# (if C<WM_CLIENT_MACHINE> has been set too).
#
sub _set_net_wm_pid_from_self {
  my ($X, $window) = @_;
  _set_card32_property ($X, $window, $X->atom('_NET_WM_PID'), $$);
}
#   _set_net_wm_pid ($X, $window, $$);

# =item C<_set_net_wm_pid ($X, $window, $pid)>
# =item C<_set_net_wm_pid ($X, $window, undef)>
# =item C<_set_net_wm_pid ($X, $window)>
#
# Set the C<_NET_WM_PID> property on C<$window> to the given C<$pid> process
# ID.  If C<$pid> is C<undef> then the property is deleted.  If C<$pid> is
# omitted then the C<$$> current process ID is set (see L<perlvar>).
#
# A window manager or similar might use this to forcibly kill an
# unresponsive client.  But it's only useful if C<WM_CLIENT_MACHINE> has
# been set to say which machine the client is running on.
#
sub _set_net_wm_pid {
  my ($X, $window, $pid) = @_;
  if (@_ < 3) { $pid = $$; }
  _set_card32_property ($X, $window, $X->atom('_NET_WM_PID'), $pid);
}


#------------------------------------------------------------------------------
# WM_NAME

# =item C<X11::Protocol::WM::set_wm_name ($X, $window, $name)>
#
# Set the C<WM_NAME> property on C<$window> (an XID) to C<$name> (a string).
# The window manager might display this as a title above the window, in a
# menu of windows, etc.
#
# If C<$name> is a Perl 5.8 wide-char string then it will be encoded as
# "STRING" or "COMPOUND_TEXT" as necessary.  Otherwise C<$name> is a byte
# string and taken to be as latin-1 "STRING" type.
#
sub _set_wm_name {
  my ($X, $window, $name) = @_;
  _set_text_property ($X, $window, X11::AtomConstants::WM_NAME, $name);
}

# =item C<_set_net_wm_name ($X, $window, $name)>
#
# Set the C<_NET_WM_NAME> property on C<$window>.  This has the same purpose
# as C<WM_NAME> above, but is encoded as "UTF8_STRING".
#
# If C<$name> is a Perl 5.8 wide-char string then it's encoded to utf8.
# Otherwise C<$name> is a byte string and assumed to be utf8 already.
#
sub _set_net_wm_name {
  my ($X, $window, $name) = @_;
  _set_utf8_string_property ($X, $window, $X->atom('_NET_WM_NAME'), $name);
}

# C<_set_utf8_string_property ($X, $window, $prop, $str)>
#
# Set a "UTF8_STRING" property C<$prop> (an atom) on C<$window>.  In Perl
# 5.8 if C<$str> is a wide-char string then it's encoded as utf8, otherwise
# C<$str> is a byte string and is assumed to be utf8 already.  If C<$str> is
# C<undef> then the property is deleted.
#
sub _set_utf8_string_property {
  my ($X, $window, $prop, $str) = @_;
  if (defined $str) {
    $X->ChangeProperty($window,
                       $prop,
                       $X->atom('UTF8_STRING'),   # type
                       8,                         # byte format
                       'Replace',
                       _to_UTF8_STRING($str));
  } else {
    $X->DeleteProperty ($window, $prop);
  }
}
sub _to_UTF8_STRING {
  my ($str) = @_;
  if (utf8->can('upgrade')) {
    utf8::upgrade($str);
    require Encode;
    return Encode::encode ('utf-8', $str); # default with substitution chars
  } else {
    return $str;
  }
}

#------------------------------------------------------------------------------
# WM_CLASS

# set_WM_CLASS()

# C<_set_wm_class_from_findbin ($X, $window)>
#
# No good?
#
# Set the C<WM_CLASS> property on $window (an XID) using the C<FindBin>
# module C<$Script>, that being the name of the running Perl script.  Any
# .pl extension is stripped to give the "instance" name.  The "class" name
# has the first letter of each word upper-cased.
#
sub _set_wm_class_from_findbin {
  my ($X, $window) = @_;
  require FindBin;
  (my $instance = $FindBin::Script) =~ s/\.pl$//;
  (my $class = $instance) =~ s/\b(\w)/\U$1/g;
  _set_wm_class ($X, $window, $instance, $class);
}

# C<_set_wm_class ($X, $window, $instance, $class)>
#
# Set the C<WM_CLASS> property on C<$window> (an XID).  This is used by the
# window manager to lookup settings and preferences for a program or a
# particular running instance of it.
#
# The C<WM_CLASS> property is "STRING" type (latin-1).  If C<$instance> or
# C<$class> are Perl 5.8 wide-char strings then they're coded to latin-1 as
# necessary.  Byte strings in C<$instance> and C<$class> are assumed to be
# latin-1 already.
#
sub _set_wm_class {
  my ($X, $window, $instance, $class) = @_;
  _set_string_property ($X, $window, X11::AtomConstants::WM_CLASS,
                        (defined $instance
                         ? _to_STRING($instance)."\0"._to_STRING($class)."\0"
                         : undef));
}

sub _to_STRING {
  my ($str) = @_;
  if (is_utf8($str)) {
    require Encode;
    # croak in the interests of not letting bad values go through unnoticed,
    # nor letting a mangled name be stored
    return Encode::encode ('iso-8859-1', $str, Encode::FB_CROAK());
  } else {
    return $str;
  }
}

#------------------------------------------------------------------------------
# WM_COMMAND

# set_WM_COMMAND()

# =item C<_set_wm_command ($X, $window, $command, $arg...)>
#
# Compound text pre-5.8 ?
#
# Set the C<WM_COMMAND> property on C<$window> (an XID).  This is a program
# name and argument strings which can be used to run or restart the client.
# C<$command> is the command name, followed by argument strings.
#
# A client program can set this at any time, or if it's participating in the
# C<WM_SAVE_YOURSELF> session manager protocol then it must set it in
# response to a C<WM_SAVE_YOURSELF> ClientMessage.
#
# The command should be something which will start the client in its current
# state as far as possible, so it might include a current document filename,
# command line options for current settings, etc.
#
# In Perl 5.8 if the C<$command> and arguments include any wide-char
# strings then they're encoded to either "STRING" or "COMPOUND_TEXT" as
# necessary (if any need "COMPOUND_TEXT" then everything is encoded to
# that).  Byte strings are taken to be latin-1 "STRING" type.
#
# If C<$command> is C<undef> it means no command and C<WM_COMMAND> is set to
# empty.  This can be used if there's no known command, in particular it can
# be a response to the session manager to say no known command.
#
sub _set_wm_command {
  my $X = shift;
  my $window = shift;
  # join() gives a wide-char result if any parts wide, upgrading byte
  # strings as if they were latin-1
  _set_text_property ($X, $window, X11::AtomConstants::WM_COMMAND,
                      (defined $_[0]
                       ? join("\0",@_)."\0"
                       : ''));
}

#------------------------------------------------------------------------------

sub _str_is_latin1 {
  my ($str) = @_;
  return (! is_utf8($str)   # byte strings are latin1
          || do {
            require Encode;
            Encode::encode ('iso-8859-1', $str, Encode::FB_QUIET());
            (length($str) == 0)    # if all converted successfully
          });
}

# =item C<_set_text_property ($X, $window, $str)>
#
# Set the given C<$prop> (an atom) property on C<$window> (an XID) using one
# of the text types "STRING" or "COMPOUND_TEXT".  If C<$str> is C<undef>
# then C<$prop> is deleted.
#
# In Perl 5.8 and up if C<$str> is a wide-char string then it's encoded to
# "STRING" (latin-1) if possible or to "COMPOUND_TEXT" if not.  Otherwise
# C<$str> is a byte string and assumed to be latin-1 "STRING".
#
sub _set_text_property {
  my ($X, $window, $prop, $str) = @_;
  my ($type, @strings);
  if (defined $str) {
    ($type, @strings) = _str_to_text_chunks ($X, $str);
  }
  _set_property_chunks ($X, $window, $prop, $type, 8, @strings);
}

sub _set_property_chunks {
  my ($X, $window, $prop, $type, $format, @chunks) = @_;
  ### _set_property_chunks()
  ### chunks: scalar(@chunks).' lens '.join(',',map{length}@chunks)
  if (@chunks) {
    my $append = 'Replace';
    while (@chunks) {
      $X->ChangeProperty($window,
                         $prop,
                         $type,
                         $format,
                         $append,
                         shift @chunks);
      $append = 'Append';
    }
  } else {
    $X->DeleteProperty ($window, $prop);
  }
}

sub _str_to_text {
  my ($X, $str) = @_;
  my $atom = X11::AtomConstants::STRING;
  if (is_utf8($str)) {
    require Encode;
    my $input = $str;
    my $bytes = Encode::encode ('iso-8859-1', $input, Encode::FB_QUIET());
    if (length($input) == 0) {
      $str = $bytes;  # latin-1
    } else {
      $atom = $X->atom('COMPOUND_TEXT');
      $input = $str;
      $str = Encode::encode ('x11-compound-text', $input, Encode::FB_WARN());
    }
  }
  return ($atom, $str);
}

sub _str_to_text_chunks {
  my ($X, $str) = @_;
  # 6xCARD32 of win,prop,type,format,mode,datalen then the text bytes
  my $maxlen = 4 * ($X->{'maximum_request_length'} - 6);
  ### $maxlen

  if (is_utf8($str)) {
    require Encode;
    my $input = $str;
    my $bytes = Encode::encode ('iso-8859-1', $input, Encode::FB_QUIET());
    if (length($input) == 0) {
      $str = $bytes;  # latin-1

    } else {
      my $codingfunc = sub { Encode::encode ('x11-compound-text', $input, Encode::FB_QUIET()) };
      $input = $str;
      &$codingfunc();
      my @ret;
      if (length($input) == 0) {
        @ret = ($X->atom('COMPOUND_TEXT'));
      } else {
        @ret = ($X->atom('UTF8_STRING'));
        $codingfunc = sub { Encode::encode ('utf-8', $input, Encode::FB_WARN()) };
      }
      my $pos = 0;
      $maxlen = int($maxlen/2) + 1;
      for (;;) {
        my $input_len = length($str) - $pos;
        last unless $input_len;
        if ($input_len > $maxlen) {
          $input_len = $maxlen;
        }
        for (;;) {
          $input = substr($str, $pos, $input_len);
          $bytes = &$codingfunc();
          if ($input_len == 1 || length($bytes) <= $maxlen) {
            last OUTER;
          }
          $input_len = int ($input_len / 2);
        }
        $pos += $input_len;
        push @ret, $bytes;
      }
      return @ret;
    }
  }

  ### use STRING
  my @ret = (X11::AtomConstants::STRING);
  my $pos = 0;
  while ($pos + $maxlen < length($str)) {
    push @ret, substr($str, $pos, $maxlen);
    $pos += $maxlen;
  }
  push @ret, substr ($str, $pos);
  return @ret;
}

#------------------------------------------------------------------------------
# WM_PROTOCOLS

# set_WM_PROTOCOLS()

# =item C<_set_wm_protocols ($X, $window, $protocol,...)>
#
# Set the C<WM_PROTOCOLS> property on C<$window> (an XID).  Each $protocol
# argument can be a string protocol name or an integer atom ID.  For
# example,
#
#     _set_wm_protocols ($X, $window, 'WM_DELETE_WINDOW', 'WM_SAVE_YOURSELF')
#
sub _set_wm_protocols {
  my $X = shift;
  my $window = shift;
  $X->ChangeProperty($window,
                     $X->atom('WM_PROTOCOLS'),  # property
                     X11::AtomConstants::ATOM,  # type
                     32,                        # format
                     'Replace',
                     pack('L*', _to_atom_ids($X,@_)));
}
sub _to_atom_ids {
  my $X = shift;
  _atoms ($X, grep {!/^\d+$/} @_);
  return map { ($_ =~ /^\d+$/ ? $_ : $X->atom($_)) } @_;
}

sub _append_wm_protocols {
  my $X = shift;
  my $window = shift;
  $X->ChangeProperty($window,
                     $X->atom('WM_PROTOCOLS'),    # key
                     X11::AtomConstants::ATOM, # type
                     32,                          # format
                     'Append',
                     pack('L*', map {_to_atom_id($X,$_)} @_));
}

# intern arguments in one round trip .
sub _atoms {
  my $X = shift;
  return map {$X->atom($_)} @_;
}

sub _atoms_parallel {
  my $X = shift;
  my @ret;
  my @names;
  my @seqs;
  my @data;
  for (;;) {
    while (@_ && @seqs < 100) {  # max 100 sliding window
      my $name = shift;
      push @names, $name;
      my $seq;
      my $atom = $X->{'atom'}->{$name};
      if (defined $atom) {
        push @data, $atom;
      } else {
        $seq = $X->send('InternAtom', $name, 0);
        ### send: $seq
        push @data, undef;
        $X->add_reply ($seq, \($data[-1]));
      }
      push @seqs, $seq;
    }

    @seqs || last;
    my $seq = shift @seqs;
    my $name = shift @names;
    my $data = shift @data;
    my $atom;
    if (defined $seq) {
      ### handle_input_for: $seq
      $X->handle_input_for ($seq);
      $X->delete_reply($seq);
      $atom = $X->unpack_reply ('InternAtom', $data);
      ### $atom
      $X->{'atom'}->{$name} = $atom;
    } else {
      $atom = $data;
    }
    push @ret, $atom;
  }
  return @ret;
}


#------------------------------------------------------------------------------
# WM_NORMAL_HINTS

# set_WM_NORMAL_HINTS

sub _set_wm_normal_hints {
  my $X = shift;
  my $window = shift;
  $X->ChangeProperty($window,
                     X11::AtomConstants::WM_NORMAL_HINTS,  # property
                     X11::AtomConstants::WM_SIZE_HINTS,    # type
                     32,                                   # format
                     'Replace',
                     _pack_wm_normal_hints ($X, @_));
}

{
  my $format = 'L18';
  my %key_to_flag = (
                     # USPosition  1     User-specified x, y
                     # USSize      2     User-specified width, height
                     # PPosition   4     Program-specified position
                     # PSize       8     Program-specified size
                     user_position    => 1,
                     user_size        => 2,
                     program_position => 4,
                     program_size     => 8,
                     min_width        => 16,
                     min_height       => 16,
                     max_width        => 32,
                     max_height       => 32,
                     width_inc        => 64,
                     height_inc       => 64,
                     min_aspect       => 128,
                     min_aspect_num   => 128,
                     min_aspect_den   => 128,
                     max_aspect       => 128,
                     max_aspect_num   => 128,
                     max_aspect_den   => 128,
                     base_width       => 256,
                     base_height      => 256,
                     win_gravity      => 512,
                    );
  sub _pack_wm_normal_hints {
    my ($X, %hint) = @_;

    my $flags = 0;
    foreach my $key (keys %hint) {
      if (defined $hint{$key}) {
        $flags |= $key_to_flag{$key};
      } else {
        croak "Unrecognised WM_NORMAL_HINTS field: ",$key;
      }
    }
    pack ($format,
          $flags,
          0,0,0,0, # pad
          $hint{'min_width'},
          $hint{'min_height'},
          $hint{'max_width'},
          $hint{'max_height'},
          $hint{'width_inc'},
          $hint{'height_inc'},
          _aspect (\%hint, 'min'),
          _aspect (\%hint, 'max'),
          $hint{'base_width'},
          $hint{'base_height'},
          $X->interp('WinGravity',$hint{'win_gravity'}),
         );
  }
}
sub _aspect {
  my ($hint, $which) = @_;
  if (defined (my $aspect = $hint->{"${which}_aspect"})) {
    return _aspect_to_numden($aspect);
  } else {
    return ($hint->{"${which}_aspect_num"}, $hint->{"${which}_aspect_den"});
  }
}
sub _aspect_to_numden {
  my ($aspect) = @_;
  ### $aspect
  if ($aspect =~ /^\d+$/) {
    ### integer
    if ($aspect > 0x7FFF_FFFF) {  # too big, or infinity if many digits
      $aspect = 0x7FFF_FFFF;
    }
    return ($aspect, 1);
  }

  if (my ($num, $den) = ($aspect =~ m{^0*(\d+)/(\d+)$})) {
    ### frac: $num, $den
    if ($num == $num-1) {  # infinity if many digits
      $num = 0x7FFF_FFFF;
      $den = 1;
    }
    if ($den == $den-1) {  # infinity if many digits
      $num = 1;
      $den = 0x7FFF_FFFF;
    }
    while ($num > 0x7FFF_FFFF || $den > 0x7FFF_FFFF) {
      $num = int ($num / 2);
      $den = int ($den / 2);
    }
    return ($num, $den);
  }
  
  if ($aspect =~ /^0*(\d*)\.(\d+?)0*$/
      && length($1)+length($2) <= 9) {
    ### decimal: $1, $2
    return ($1.$2, '1'.('0' x length($2)));
  }
  
  ### float, scale up in binary
  my $den = 1;
  while ($aspect < 0x4000_0000 && $den < 0x4000_0000) {
    if ($aspect == int($aspect)) {
      last;
    }
    $aspect *= 2;
    $den *= 2;
    ### up to: $aspect,$den
  }
  return (int($aspect + 0.5), $den);
}
# printf "%d %d", _aspect_frac('.123456789');



#------------------------------------------------------------------------------
# _NET_WM_USER_TIME

sub _get_net_user_time_window {
  my ($X, $window) = @_;
  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($window,
                       $X->atom('_NET_WM_USER_TIME_WINDOW'),  # property
                       X11::AtomConstants::WINDOW,  # type
                       0,    # offset
                       1,    # length, 1 x CARD32
                       0);   # delete
  if ($format == 32) {
    return scalar (unpack 'L', $value);
  } else {
    return undef;
  }
}


#------------------------------------------------------------------------------
# _NET_FRAME_EXTENTS

# get_NET_FRAME_EXTENTS

# =item C<my ($left,$right, $top,$bottom) = _get_net_frame_extents ($X, $window)>
#
# Return the C<_NET_FRAME_EXTENTS> property from C<$window>.  This is set by
# the window manager to the size in pixels of any decoration frame it puts
# around C<$window>.  If there's no such property set then the return is an
# empty list.
#
sub _get_net_frame_extents {
  my ($X, $window) = @_;
  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($window,
                       $X->atom('_NET_FRAME_EXTENTS'),  # property
                       X11::AtomConstants::CARDINAL,    # type
                       0,    # offset
                       4,    # length, 4 x CARD32
                       0);   # delete
  if ($format == 32) {
    return scalar (unpack 'L4', $value);
  } else {
    return;
  }
}


1;
__END__

=for stopwords Math-Image Ryde

=head1 NAME

App::MathImage::X11::Protocol::Splash -- temporary splash window

=for test_synopsis my ($X, $id)

=head1 SYNOPSIS

 use App::MathImage::X11::Protocol::Splash;
 my $splash = App::MathImage::X11::Protocol::Splash->new
                (X => $X,
                 pixmap => $id);
 $splash->popup;
 # ...
 $splash->popdown;

=head1 DESCRIPTION

(Unattended redraw not working ...)

...

=head1 FUNCTIONS

=over 4

=item C<< $splash = App::MathImage::X11::Protocol::Splash->new (key=>value,...) >>

Create and return a new Splash object.  The key/value parameters are

    X         X11::Protocol object (mandatory)
    pixmap    xid of pixmap to display
    width     integer (optional)
    height    integer (optional)

=item C<< $splash->popup >>

=item C<< $splash->popdown >>

=back

=head1 SEE ALSO

L<X11::Protocol>,
L<X11::Protocol::Other>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
