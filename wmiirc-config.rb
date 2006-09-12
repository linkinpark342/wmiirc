# Ruby-based configuration file for wmii.
=begin
  Copyright 2006 Suraj N. Kurapati

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

$: << File.dirname(__FILE__)
require 'rc'


## WM startup

FS = Wmii.fs
FS.event = "Start wmiirc\n" # terminate existing wmiirc processes


## executable programs

# names of external programs
PROGRAM_MENU = find_programs( ENV['PATH'].squeeze(':').split(':') )

# names of internal actions
ACTION_MENU = find_programs('~/dry/apps/wmii/etc/wmii-3', File.dirname(__FILE__))


## UI configuration

ENV['WMII_FONT'] = '-misc-fixed-medium-r-normal--18-120-100-100-c-90-iso10646-1'
ENV['WMII_SELCOLORS']='#ffffff #285577 #4c7899'
ENV['WMII_NORMCOLORS']='#222222 #eeeeee #666666'

system %{xsetroot -solid '#333333'}


## WM configuration

FS.def.border = 2

FS.def.font = ENV['WMII_FONT']
FS.def.selcolors = ENV['WMII_SELCOLORS']
FS.def.normcolors = ENV['WMII_NORMCOLORS']

FS.def.colmode = 'default'
FS.def.colwidth = 0

FS.def.rules = <<EOS
/jEdit.*/ -> code
/Buddy List.*/ -> chat
/XChat.*/ -> chat
/.*thunderbird.*/ -> mail
/Gimp.*/ -> gimp
/QEMU.*/ -> ~
/MPlayer.*/ -> ~
/xconsole.*/ -> ~
/alsamixer.*/ -> ~
/.*/ -> !
/.*/ -> 1
EOS


## key configuration

# Symbolic name of modifier key.
MODKEY = 'Mod1'

# Symbolic name for up direction key.
UP = 't'

# Symbolic name for down direction key.
DOWN = 'n'

# Symbolic name for left direction key.
LEFT = 'h'

# Symbolic name for right direction key.
RIGHT = 's'

# Keycode for the primary mouse button.
PRIMARY = 1

# Keycode for the middle mouse button.
MIDDLE = 2

# Keycode for the secondary mouse button.
SECONDARY = 3


# Initial key sequence used by all shortcuts.
ACTION = "#{MODKEY}-Control-"

FOCUS = ACTION
SEND = "#{ACTION}m,"
SWAP = "#{ACTION}w,"
LAYOUT = "#{ACTION}z,"
GROUP = "#{ACTION}g,"
MENU = ACTION
PROGRAM = ACTION


# Shortcut key sequences and their associated logic.
SHORTCUTS = {
  # focus previous view
  "#{FOCUS}comma" => lambda do
    cycle_view :left
  end,

  # focus next view
  "#{FOCUS}period" => lambda do
    cycle_view :right
  end,

  # focus previous area
  "#{FOCUS}#{LEFT}" => lambda do
    Wmii.current_view.ctl = 'select prev'
  end,

  # focus next area
  "#{FOCUS}#{RIGHT}" => lambda do
    Wmii.current_view.ctl = 'select next'
  end,

  # focus floating area
  "#{FOCUS}space" => lambda do
    Wmii.current_view.ctl = 'select toggle'
  end,

  # focus previous client
  "#{FOCUS}#{UP}" => lambda do
    Wmii.current_area.ctl = 'select prev'
  end,

  # focus next client
  "#{FOCUS}#{DOWN}" => lambda do
    Wmii.current_area.ctl = 'select next'
  end,


  # apply equal spacing layout to currently focused column
  "#{LAYOUT}w" => lambda do
    Wmii.current_area.mode = 'default'
  end,

  # apply stacked layout to currently focused column
  "#{LAYOUT}v" => lambda do
    Wmii.current_area.mode = 'stack'
  end,

  # apply maximized layout to currently focused column
  "#{LAYOUT}m" => lambda do
    Wmii.current_area.mode = 'max'
  end,

  # maximize the floating area's focused client
  "#{LAYOUT}z" => lambda do
    Wmii.current_view[0].sel.geom = '0 0 east south'
  end,


  # apply tiling layout to the currently focused view
  "#{LAYOUT}t" => lambda do
    Wmii.current_view.tile!
  end,

  # apply gridding layout to the currently focused view
  "#{LAYOUT}g" => lambda do
    Wmii.current_view.grid!
  end,


  # add/remove the currently focused client from the selection
  "#{GROUP}g" => lambda do
    Wmii.current_client.invert_selection!
  end,

  # add all clients in the currently focused view to the selection
  "#{GROUP}a" => lambda do
    Wmii.current_view.select!
  end,

  # invert the selection in the currently focused view
  "#{GROUP}i" => lambda do
    Wmii.current_view.invert_selection!
  end,

  # nullify the selection
  "#{GROUP}n" => lambda do
    Wmii.select_none!
  end,


  # launch an internal action by choosing from a menu
  "#{MENU}i" => lambda do
    action = show_menu(ACTION_MENU)
    system(action << '&') unless action.empty?
  end,

  # launch an external program by choosing from a menu
  "#{MENU}e" => lambda do
    program = show_menu(PROGRAM_MENU)
    system(program << '&') unless program.empty?
  end,

  # focus any view by choosing from a menu
  "#{MENU}Shift-v" => lambda do
    Wmii.focus_view(show_menu(Wmii.tags))
  end,

  "#{MENU}a" => lambda do
    focus_client_from_menu
  end,


  "#{PROGRAM}x" => lambda do
    system 'terminal &'
  end,

  "#{PROGRAM}k" => lambda do
    system 'epiphany &'
  end,

  "#{PROGRAM}j" => lambda do
    system 'nautilus --no-desktop &'
  end,


  "#{SEND}#{LEFT}" => lambda do
    Wmii.selected_clients.each do |c|
      c.ctl = 'sendto prev'
    end
  end,

  "#{SEND}#{RIGHT}" => lambda do
    Wmii.selected_clients.each do |c|
      c.ctl = 'sendto next'
    end
  end,

  "#{SEND}space" => lambda do
    Wmii.selected_clients.each do |c|
      c.ctl = 'sendto toggle'
    end
  end,

  "#{SEND}Delete" => lambda do
    Wmii.selected_clients.each do |c|
      c.ctl = 'kill'
    end
  end,

  "#{SEND}t" => lambda do
    change_tag_from_menu
  end,

  # remove currently focused view from current selection's tags
  "#{SEND}Shift-minus" => lambda do
    curTag = Wmii.current_view.name

    Wmii.selected_clients.each do |c|
      c.untag! curTag
    end
  end,

  "#{ACTION}b" => lambda do
    toggle_temp_view
  end,

  # wmii-2 style detaching
  "#{ACTION}d" => lambda do
    detach_selection
  end,

  # wmii-2 style detaching
  "#{ACTION}Shift-d" => lambda do
    attach_last_client
  end,

  # toggle maximizing the currently focused client to full screen
  "#{SEND}m" => lambda do
    SHORTCUTS["#{SEND}space"].call
    SHORTCUTS["#{LAYOUT}z"].call
  end,

  # swap the currently focused client with the one to its left
  "#{SWAP}#{LEFT}" => lambda do
    Wmii.current_client.ctl = 'swap prev'
  end,

  # swap the currently focused client with the one to its right
  "#{SWAP}#{RIGHT}" => lambda do
    Wmii.current_client.ctl = 'swap next'
  end,

  # swap the currently focused client with the one below it
  "#{SWAP}#{DOWN}" => lambda do
    Wmii.current_client.ctl = 'swap down'
  end,

  # swap the currently focused client with the one above it
  "#{SWAP}#{UP}" => lambda do
    Wmii.current_client.ctl = 'swap up'
  end,
}

10.times do |i|
  k = (i - 1) % 10	# associate '1' with the leftmost label, instead of '0'

  # focus _i_th view
  SHORTCUTS["#{FOCUS}#{i}"] = lambda do
    Wmii.focus_view Wmii.tags[k] || i
  end

  # send selection to _i_th view
  SHORTCUTS["#{SEND}#{i}"] = lambda do
    Wmii.selected_clients.each do |c|
      c.tags = Wmii.tags[k] || i
    end
  end

  # send selection to _i_th area
  SHORTCUTS["#{SEND}Shift-#{i}"] = lambda do
    dstCol = Wmii.current_view[i]

    Wmii.selected_clients.each do |c|
      dstCol.insert! c
    end
  end

  # apply grid layout with _i_ clients per column
  SHORTCUTS["#{LAYOUT}#{i}"] = lambda do
    Wmii.current_view.grid! i
  end

  # add _i_th view to current selection's tags
  SHORTCUTS["#{SEND}equal,#{i}"] =
  SHORTCUTS["#{SEND}Shift-equal,#{i}"] = lambda do
    Wmii.selected_clients.each do |c|
      c.tag! Wmii.tags[k] || i
    end
  end

  # remove _i_th view from current selection's tags
  SHORTCUTS["#{SEND}minus,#{i}"] = lambda do
    Wmii.selected_clients.each do |c|
      c.untag! Wmii.tags[k] || i
    end
  end
end

# jump to view whose name begins with the pressed key
('a'..'z').each do |char|
  SHORTCUTS["#{MENU}v,#{char}"] = lambda do
    choices = Wmii.tags
    choices.delete Wmii.current_view.name

    if view = choices.select {|t| t =~ /^#{char}/i}.first
      Wmii.focus_view view
    end
  end
end

FS.def.grabmod = MODKEY
FS.def.keys = SHORTCUTS.keys.join("\n")


## status bar

Thread.new do
  sb = Ixp::Node.new('/bar/status', true)
  sb.colors = ENV['WMII_NORMCOLORS']

  loop do
    cpuLoad = `uptime`.scan(/\d+\.\d+/).join(' ')
    diskSpace = `df -h ~`.split[-3..-1].join(' ')

    5.times do
      sb.data = "#{Time.now.to_s} | #{cpuLoad} | #{diskSpace}"
      sleep 1
    end
  end
end


## WM event loop

begin
  IO.popen('wmiir read /event') do |io|
    while event = io.readline.chomp
      type, arg = event.split($;, 2)

      case type
        when 'Start'
          if arg == 'wmiirc'
            LOG.info "Exiting because another wmiirc has started."
            exit
          end

        when 'BarClick'
          viewId, mouseBtn = arg.split

          case mouseBtn.to_i
            when PRIMARY
              Wmii.focus_view viewId

            when MIDDLE
              # add view to selection's tags
              Wmii.selected_clients.each do |c|
                c.tag! viewId
              end

            when SECONDARY
              # remove view from selection's tags
              Wmii.selected_clients.each do |c|
                c.untag! viewId
              end
          end

        when 'ClientClick'
          clientId, mouseBtn = arg.split

          case mouseBtn.to_i
            when MIDDLE, SECONDARY
              Wmii::Client.new("/client/#{clientId}").invert_selection!
          end

        when 'Key'
          SHORTCUTS[arg].call
      end
    end
  end
rescue EOFError
  LOG.fatal "wmiiwm has quit"
  exit 1
end
