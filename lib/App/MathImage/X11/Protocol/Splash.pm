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
use X11::Protocol::WM;
use X11::AtomConstants;

use vars '$VERSION';
$VERSION = 51;

# uncomment this to run the ### lines
#use Smart::Comments;

# /usr/share/doc/xorg-docs/specs/CTEXT/ctext.txt.gz
# /usr/share/doc/xorg-docs/specs/ICCCM/icccm.txt.gz
# lcCT.c
# RFC2237 2022-jp
# RFC1557 2022-kr

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
# WM_STATE

# ($state, $icon_window) = _get_wm_state ($X, $window)
#
# Get the current state of C<$window>.  $state is either a string or integer
# according to $X->{'do_interp'}.  The possible states are
#     WithdrawnState    0
#     NormalState       1
#     IconicState       3
# ZoomState (2) and InactiveState (4) are no longer in the ICCCM and
# probably won't be encountered, but are recognised for the return.
#
# $icon_window is the window used by the window manager to display the icon
# of C<$window>, or None if no such window (string "None" under the usual
# $X->{'do_interp'}, or 0 otherwise).
#
# C<$icon_window> might be the C<icon_window> given by the client in
# C<WM_HINTS>, or it might be created by the window manager.  Either way the
# client can draw into it for animations etc (listening for Expose events if
# necessary).
#
sub _get_wm_state {
  my ($X, $window) = @_;
  my $xa_wm_state = $X->atom('WM_STATE');
  my ($value, $type, $format, $bytes_after)
    = $X->GetProperty ($window,
                       $xa_wm_state,  # property
                       $xa_wm_state,  # type
                       0,             # offset
                       2,             # length, 2 x CARD32
                       0);            # delete
  if ($format == 32) {
    my ($state, $icon_window) = unpack 'L*', $value;
    return (_wmstate_interp($X,$state), _window_interp($icon_window));
  } else {
    return;
  }
}

sub _window_interp {
  my ($X, $window) = @_;
  if ($X->{'do_interp'} && $window == 0) {
    return 'None';
  } else {
    return $window;
  }
}

{
  # DontCareState==0 no longer ICCCM
  my @wmstate = ('WithdrawnState', # 0
                 'NormalState',    # 1
                 'ZoomState',      # 2, no longer ICCCM
                 'IconicState',    # 3
                 'InactiveState',  # 4, no longer in ICCCM
                );
  sub _wmstate_interp {
    my ($X, $num) = @_;
    if ($X->{'do_interp'} && defined (my $str = $wmstate[$num])) {
      return $str;
    }
    return $num;
  }
}


#------------------------------------------------------------------------------
# WM_CLIENT_MACHINE

# Set the WM_CLIENT_MACHINE property on $window using Sys::Hostname.
# Currently if that module can't determine a hostname by its various
# gambits then the WM_CLIENT_MACHINE is deleted.  Should it instead leave it
# unchanged, or return a flag to say if set?
sub _set_wm_client_machine_from_syshostname {
  my ($X, $window) = @_;
  require Sys::Hostname;
  _set_wm_client_machine ($X, $window, eval { Sys::Hostname::hostname() });
}

# Set the WM_CLIENT_MACHINE property on $window.
# Usually $hostname will be ASCII-only, though in Perl 5.8.1 up a wide-char
# string will be encoded as "COMPOUND_TEXT" type if necessary.
sub _set_wm_client_machine {
  my ($X, $window, $hostname) = @_;
  _set_text_property ($X, $window,
                      X11::AtomConstants::WM_CLIENT_MACHINE, $hostname);
}


#------------------------------------------------------------------------------
# _NET_WM_PID

# Set the _NET_WM_PID property on $window to the process ID of the current
# process, ie. Perl $$ variable.  A window manager or similar can use this
# to forcibly kill an unresponsive client, if WM_CLIENT_MACHINE has been set
# too.
sub _set_net_wm_pid_from_self {
  my ($X, $window) = @_;
  _set_single_property ($X, $window, $X->atom('_NET_WM_PID'), $$);
}
#   _set_net_wm_pid ($X, $window, $$);
# sub _set_net_wm_pid {
#   my ($X, $window, $pid) = @_;
# }


#------------------------------------------------------------------------------
# WM_NAME

# Set the WM_NAME property on $window.  The window manager displays this as
# a title above the window or in a menu of windows, etc.
#
# In Perl 5.8.1 and up if $name is a wide-char string then it will be
# encoded as "COMPOUND_TEXT" if necessary.  Otherwise $name is a byte string
# and taken to be as latin-1 "STRING" type.
#
sub _set_wm_name {
  my ($X, $window, $name) = @_;
  _set_text_property ($X, $window, X11::AtomConstants::WM_NAME, $name);
}

# Set the _NET_WM_NAME property on $window.  This has the same purpose as
# WM_NAME, but is encoded as UTF8_STRING.
#
# In Perl 5.8 if $name is a wide-char string then it's encoded as utf8.
# Otherwise $name is a byte string and assumed to be utf8 already.
#
sub _set_net_wm_name {
  my ($X, $window, $name) = @_;
  _set_utf8_string_property ($X, $window, $X->atom('_NET_WM_NAME'), $name);
}

# Set a UTF8_STRING property $prop on $window.
# In Perl 5.8 and up a wide-char string is encoded appropriately.
# If $str is a byte string then it's assumed to be utf8.
# If $str is a byte string then it's upgraded from latin-1 to utf8.
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

# Set the WM_CLASS property on $window (an XID) using the FindBin module
# $Script.  Any .pl extension is stripped, and the class has the first
# letter of each word upper-cased.
#
sub _set_wm_class_from_findbin {
  my ($X, $window) = @_;
  require FindBin;
  (my $instance = $FindBin::Script) =~ s/\.pl$//;
  (my $class = $instance) =~ s/\b(\w)/\U$1/g;
  _set_wm_class ($X, $window, $instance, $class);
}

# Set the WM_CLASS property on $window (an XID).
#
# $instance and $class should be latin1 strings.  In Perl 5.8.1 and up
# wide-char strings will be converted to latin1 as necessary, otherwise byte
# strings are taken to be latin1.
#
sub _set_wm_class {
  my ($X, $window, $instance, $class) = @_;
  _set_string_property ($X, $window, X11::AtomConstants::WM_CLASS,
                        (defined $instance
                         ? _to_STRING($instance)."\0"._to_STRING($class)."\0"
                         : undef));
}

#------------------------------------------------------------------------------
# WM_COMMAND

# Set the C<WM_COMMAND> property on C<$window> (an XID).
# C<$program> should be the command name, followed by argument strings.
#
# A client program should set this in response to a C<WM_SAVE_YOURSELF>
# message from the session manager, if the client has asked for that in its
# C<WM_PROTOCOLS>.  The value should be a command which will restart the
# client in its current state as far as possible.
#
# In Perl 5.8.1 if any of the parts are a wide-char string then
# "COMPOUND_TEXT" is used if necessary.  Otherwise all the parts are byte
# strings and taken to be latin-1 "STRING" type.
#
# If C<$program> is C<undef> it means no command and WM_COMMAND is set to
# empty.  This can be used as a response to the session manager if the
# command can't be determined, etc.
#
sub _set_wm_command {
  my ($X, $window, $program, @args) = @_;
  _set_text_property ($X, $window, X11::AtomConstants::WM_COMMAND,
                      (defined $program ? join("\0",$program,@args)."\0" : ''));
}

#------------------------------------------------------------------------------

sub _str_is_latin1 {
  my ($str) = @_;
  return (! utf8->can('is_utf8')     # pre perl 5.8 is latin1
          || ! utf8::is_utf8($str)   # byte strings are latin1
          || do {
            require Encode;
            Encode::encode ('iso-8859-1', $str, Encode::FB_QUIET());
            (length($str) == 0)    # if all converted successfully
          });
}

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

sub _str_to_text_chunks {
  my ($X, $str) = @_;
  # 6xCARD32 of win,prop,type,format,mode,datalen then the text bytes
  my $maxlen = 4 * ($X->{'maximum_request_length'} - 6);
  ### $maxlen

  if (utf8->can('is_utf8') && utf8::is_utf8($str)) {
    require Encode;
    my $input = $str;
    my $bytes = Encode::encode ('iso-8859-1', $input, Encode::FB_QUIET());
    if (length($input) == 0) {
      $str = $bytes;  # latin-1

    } else {
      my $codingfunc = sub { _encode_compound (__PACKAGE__, $input, 1); };
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
            last;
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

sub _to_STRING {
  my ($str) = @_;
  if (utf8->can('is_utf8') && utf8::is_utf8($str)) {
    require Encode;
    return Encode::encode ('iso-8859-1', $str); # with "?" substitution chars
  } else {
    return $str;
  }
}

my @coding = ('iso-8859-1',
              'iso-8859-2',
              'iso-8859-3',
              'iso-8859-4',
              'iso-8859-7',
              'iso-8859-6',
              'iso-8859-8',
              'iso-8859-5',
              'iso-8859-9',
              #'iso-2022-jp',
              # 'iso-2022-kr',
              # gb2312
              );
# Esc 0x2D switch GR 0x80-0xFF
my @esc = ("\033\055\101", # iso-8859-1
           "\033\055\102", # iso-8859-2
           "\033\055\103", # iso-8859-3
           "\033\055\104", # iso-8859-4
           "\033\055\106", # iso-8859-7
           "\033\055\107", # iso-8859-6
           "\033\055\110", # iso-8859-8
           "\033\055\114", # iso-8859-5
           "\033\055\115", # iso-8859-9
           '',
           '',
          );
# xfree86 utf8 in compound: ESC % G --UTF-8-BYTES-- ESC % @
#                              25 47                    25 40
sub _encode_compound {
  my ($self, $str, $chk) = @_;
  require Encode;
  # as much initial latin1 as possible
  my $ret = Encode::encode ('iso-8859-1', $str, Encode::FB_QUIET());
  my $in_ascii = 1;
  my $in_latin1 = 1;
  while (length($str)) {
    ### str length: length($str)
    my $longest_bytes = '';
    my $esc;
    my $remainder = $str;
    foreach my $i (0 .. $#coding) {
      last unless length($remainder);
      my $input = $str;
      my $bytes = Encode::encode ($coding[$i], $input, Encode::FB_QUIET());
      if (length($input) < length($remainder)) {
        $longest_bytes = $bytes;
        $esc = $esc[$i];
        $remainder = $input;
        $in_latin1 = ($i == 0);
        $in_ascii = 1;
      }
    }
    # foreach my $coding ('jp', 'kr') {
    #   last unless length($remainder);
    #   my $input = $str;
    #   my $bytes = Encode::encode ("euc-$coding", $input, Encode::FB_QUIET());
    #   ### coding: "euc-$coding"
    #   ### $bytes
    #   ### remainder: length($input)
    #   if (length($input) < length($remainder)) {
    #     my $input2 = substr ($str, 0, length($str)-length($input));
    #     ### $input2
    #     $bytes = Encode::encode ("iso-2022-$coding", $input2,
    #                              Encode::FB_QUIET());
    #     ### coding: "iso-2022-$coding"
    #     ### $bytes
    #     ### remainder: length($input2)
    #     ### assert: length($input2) == 0
    #     if (length($input2) == 0) {
    #       $longest_bytes = $bytes;
    #       $esc = '';
    #       $remainder = $input;
    #       $in_latin1 = 0;
    #       $in_ascii = 0;
    #     }
    #   }
    # }
    ### $longest_bytes
    ### $esc
    if (length($longest_bytes)) {
      $ret .= $esc;
      $ret .= $longest_bytes;
      $str = $remainder;
    } else {
      if ($chk) {
        ### nothing converted, stop
        last;
      } else {
        if (! $in_ascii) {
          $ret .= $esc[0];
          $in_ascii = 1;
          $in_latin1 = 1;
        }
        $ret .= '?';
        $str = substr ($str, 1);
      }
    }
  }
  if (! $in_latin1) {
    $ret .= $esc[0];
  }
  if ($chk) {
    $_[1] = $str;  # unconverted part, if any
  }
  return $ret;
}

# xfree86 utf8 in compound: ESC % G --UTF-8-BYTES-- ESC % @
#                              25 47                    25 40

my %esc_to_coding = ((map { $esc[$_] => $coding[$_] } 0 .. $#coding),
                     "\x1B\x28\x42" => 'ascii',

                     "\x1B\x28\x4A" => 'ascii',       # jis0201 GL is ascii
                     "\x1B\x29\x4A" => 'jis0201-raw', # GR

                     # \x24 means 2-bytes per char
                     "\x1B\x24\x28\x41" => 'gb2312',
                     "\x1B\x24\x28\x42" => 'jis0208-raw',# 208-1983 or 208-1990
                     "\x1B\x24\x28\x43" => 'ksc5601-raw',
                     "\x1B\x24\x28\x44" => 'jis0212-raw',# 212-1990

                     "\x1B\x24\x28\x47" => 'cns11643-1', # Encode::HanExtra
                     "\x1B\x24\x28\x48" => 'cns11643-2',
                     "\x1B\x24\x28\x49" => 'cns11643-3',
                     "\x1B\x24\x28\x4A" => 'cns11643-4',
                     "\x1B\x24\x28\x4B" => 'cns11643-5',
                     "\x1B\x24\x28\x4C" => 'cns11643-6',
                     "\x1B\x24\x28\x4D" => 'cns11643-7',

                     # Emacs extensions
                     "\x1B\x24\x28\x30" => 'big5-eten', # E0
                     "\x1B\x24\x28\x31" => 'big5-eten', # E1

                     "\x1B\x25\x47" => 'utf-8',
                    );
my %coding_is_lo = ('ascii' => 1,
                    'jis0208-raw' => 1,
                    'jis0212-raw' => 1,
                    'ksc5601-raw' => 1,
                    'gb2312'      => 1,
                    'cns11643-1' => 1,
                    'cns11643-2' => 1,
                    'cns11643-3' => 1,
                    'cns11643-4' => 1,
                    'cns11643-5' => 1,
                    'cns11643-6' => 1,
                    'cns11643-7' => 1,
                   );
my %coding_is_hi = ('big5-eten' => 1,
                   );
#use Smart::Comments;
sub _decode_compound {
  my ($self, $bytes, $chk) = @_;
  ### _decode_compound(): 'len='.length($bytes)
  require Encode;
  my $gl_coding = 'ascii';
  my $gr_coding = 'iso-8859-1';
  my $lo_to_hi = 0;
  my $ret = '';
 OUTER: while ((pos($bytes)||0) < length $bytes) {
    $bytes =~ m{\G(.*?)  # $1 part
                (\x1B    # $2 esc
                  (?:[\x28\x2D].   # 1-byte
                  |\x24[\x28\x29]. # 2-byte
                  |\x25\x47        # xfree86 utf-8
                  )
                |$)
             }gx or die;
    my $part_bytes = $1;
    my $esc = $2;

    for (;;) {
      my $coding;
      if ($part_bytes =~ /\G([\x00-\x7F]+)/gc) {
        $coding = $gl_coding;
        if ($coding_is_hi{$coding}) {
          $part_bytes =~ tr/\x21-\x7E/\xA1-\xFE/;
        }
      } elsif ($part_bytes =~ /\G([^\x00-\x7F]+)/gc) {
        $coding = $gr_coding;
        if ($coding_is_lo{$coding}) {
          $part_bytes =~ tr/\xA1-\xFE/\x21-\x7E/;
        }
      } else {
        last;
      }
      my $half_bytes = $1;

      while (length $half_bytes) {
        ### $half_bytes
        ### $coding
        $ret .= Encode::decode ($coding, $half_bytes,
                                $chk ? Encode::FB_QUIET() : Encode::FB_DEFAULT());
        ### now ret: $ret
        if (length $half_bytes) {
          if ($chk) {
            $_[1] = substr ($bytes,
                            pos($bytes) - length($esc)
                            - length($part_bytes) - length($half_bytes));
            last OUTER;
          } else {
            $ret .= chr(0xFFFD);
            $half_bytes = substr($half_bytes, 1);
          }
        }
      }
    }

    my $coding;
    my $gref;
    if (($esc =~ s/\x1B\x24?\x29/\x1B\x24\x28/)
        ||
        ($esc =~ s/\x1B\x24?\x29/\x1B\x24\x28/)) {
      $gref = \$gl_coding;
    } else {
      $gref = \$gr_coding;
    }
    $coding = $esc_to_coding{$esc};
    if (! defined $coding
        || ($coding =~ /^cns/
            && ! eval { require Encode::HanConvert; 1 })) {
      ### no coding: $coding
      if ($chk) {
        $_[1] = substr ($bytes, pos($bytes) - length($esc));
        last;
      } else {
        $ret .= chr(0xFFFD);
      }
    }
    $$gref = $coding;
  }
  ### final ret: $ret
  return $ret;
}

#------------------------------------------------------------------------------
# WM_PROTOCOLS

# _set_wm_protocols ($X, $window, $protocol,...)
# Set the WM_PROTOCOLS property on $window (an XID).
#
# Each $protocol argument can be a string protocol name or a corresponding
# integer atom ID.
#
#     _set_wm_protocols ($X, $window,  'WM_DELETE_WINDOW', 'WM_SAVE_YOURSELF')
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


#------------------------------------------------------------------------------
# WM_NORMAL_HINTS

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
# MOTIF_WM_HINTS

sub _set_motify_wm_hints {
  my $X = shift;
  my $window = shift;
  $X->ChangeProperty($window,
                     $X->atom('_MOTIF_WM_HINTS'),  # property
                     $X->atom('_MOTIF_WM_HINTS'),  # type
                     32,                          # format
                     'Replace',
                     _pack_motify_wm_hints ($X, @_));
}

{
  # /usr/include/Xm/MwmUtil.h
  my $format = 'L5';
  my %input_mode = (modeless                  => 0,
                    primary_application_modal => 1,
                    application_modal         => 1,
                    system_modal              => 2,
                    full_application_modal    => 3,
                   );
  my %key_to_flag = (functions   => 1,
                     decorations => 2,
                     input_mode  => 4,
                     status      => 8,
                    );
  my %arrays = (functions => { all      => 1,
                               resize   => 2,
                               move     => 4,
                               minimize => 8,
                               maximize => 16,
                               close    => 32 },
                decorations => { all      => 1,
                                 border   => 2,
                                 resizeh  => 4,
                                 title    => 8,
                                 menu     => 16,
                                 minimize => 32,
                                 maximize => 64 },
               );
  sub _pack_motif_wm_hints {
    my ($X, %hint) = @_;

    my $flags = 0;
    foreach my $key (keys %hint) {
      if (defined $hint{$key}) {
        $flags |= $key_to_flag{$key};
      } else {
        croak "Unrecognised MOTIF_WM_HINTS field: ",$key;
      }
    }
    foreach my $field (keys %arrays) {
      my $bits = 0;
      if (my $h = $hint{$field}) {
        foreach my $key (@$h) {
          if (defined (my $bit = $arrays{$field}->{$key})) {
            $bits |= $bit;
          } else {
            croak "Unrecognised MOTIF_WM_HINTS ",$field," field: ",$key;
          }
        }
      }
      $hint{$field} = $bits;
    }
    my $decorations = $hint{'decorations'};
    pack ($format,
          $flags,
          $hint{'functions'},
          $hint{'decorations'},
          $hint{'input_mode'}  || 0,
          $hint{'status'}      || 0);
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

Copyright 2010, 2011 Kevin Ryde

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
