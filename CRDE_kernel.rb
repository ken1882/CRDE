#=============================================================================#
#   CRDE - Kernel                                                             #
#   Version: 0.1.2                                                            #  
#   Author: Compeador                                                         #  
#   Last update: 2019.05.13                                                   #  
#=============================================================================#
$imported = {} if $imported.nil?
$imported[:CRDE_Kernel] = true
#=============================================================================#
#                               ** Update log **                              #
#-----------------------------------------------------------------------------#
#                                                                             #
# -- 2019.05.02: Start the script                                             #
#                                                                             #
#=============================================================================#
#                       ** End-User License Agreement **                      #
#-----------------------------------------------------------------------------#
#  1. Copyright and Redistribution:                                           #
#       All codes were written by me(Compeador), and you(the user) may edit   #
#  the code for your own need without permission in non-commercial project.   #
#  Redistribution: You're allowed to redistribute this script if and only if  #
#  the script you share is from the original source, so you may not share the #
#  script after your edits. Send pull request to share your edits instead.    #
#                  (Contact me for commerical use.)                           #
#                                                                             #
# 2. Service Information:                                                     #
#       I do not responsible for any compatibility issue with other scripts,  #
# but accepts both request and commission to do patches.                      #
#                                                                             #
#=============================================================================#
#                              ** User Manual **                              #
#-----------------------------------------------------------------------------#
# > Introduction:                                                             #
#       This script overwrites and alias lots of default class method for     #
# other CRDE script.                                                          #
# This script is required for all CRDE scripts even if it has not D&D/TRPG-   #
# -like featrues.                                                             #
#=============================================================================#
#                            ** Compatibility **                              #
#-----------------------------------------------------------------------------#
#   > Unknown                                                                 #
#                                                                             #
#       ** Place this script below the scripts mentioned above **             #
#                                                                             #
#=============================================================================#

#=============================================================================
# ** Module of this script
#=============================================================================
module CRDE
  module Config
    # If set to true, secure codes will be implemented to avoid your
    # game being exploited. Notice that nothing is 100% guaranteed safe
    SecureMode = true

    # Default encoding
    DefaultEncoding = "utf-8"
    $default_encoding = DefaultEncoding
  end # Config
  #=============================================================================
  module Kernel
    Version      = "0.1.2"
    PaddingWidth = 12
    #------------------------------------------------------------------------------
    def self.report_exception(error, ex_caller=[])
      scripts_name = load_data('Data/Scripts.rvdata2')
      scripts_name.collect! {|script|  script[1]  }
      backtrace = []
      (error.backtrace + ex_caller).each_with_index {|line,i|
        if line =~ /{(.*)}(.*)/
          backtrace << (scripts_name[$1.to_i] + $2)
        elsif line.start_with?(':1:')
          break
        else
          backtrace << line
        end
      }
      error_line = backtrace.first
      backtrace[0] = ''
      err_class = " (#{error.class})"
      back_trace_txt = backtrace.join("\n\tfrom ")
      error_txt = sprintf("%s %s %s %s %s %s",error_line, ": ", error.message, err_class, back_trace_txt, "\n" )
      print error_txt
      return error_txt
    end
    #--------------------------------------------------------------------------
    # * Text wrap for window contents
    #--------------------------------------------------------------------------
    def self.textwrap(full_text, line_width, sample_bitmap = nil)
      return [] if full_text.nil?
      if sample_bitmap.nil?
        using_sample = true
        sample_bitmap = Bitmap.new(1,1)
      else
        using_sample  = false
      end
      raise TypeError unless full_text.is_a?(String)
      full_text   = full_text.dup.force_encoding($default_encoding)
      
      wraped_text = []
      cur_width   = PaddingWidth
      line        = ""
      bk_full     = '　'.force_encoding($default_encoding)
      bk_half     = ' '.force_encoding($default_encoding)
      strings     = full_text.gsub(bk_full, bk_half).split(/[\r\n ]+/i)
      strs_n      = strings.size
      space_width = sample_bitmap.text_size(' ').width
      minus_width = sample_bitmap.text_size('-').width
      
      # while any string segment unprocessed
      while (str = strings.first)
        next if str.length == 0
        width = sample_bitmap.text_size(str).width
        endl  = false
        # if the segment width larger than display width
        if width + PaddingWidth >= line_width
          line      = ""
          cur_width = minus_width
          strlen    = str.length
          processed = false
          last_i    = 0
          # process each character on by one
          for i in 0...strlen
            width = sample_bitmap.text_size(str[i]).width
            last_i = i
            # unable to display character
            if !processed && cur_width + width >= line_width
              sample_bitmap.dispose if using_sample
              return [full_text]
            elsif cur_width + width < line_width
              cur_width += width
              line += str[i]
              processed = true
            else
              break
            end
          end
          # continue symbol character
          line += '-'
          # replace with left unprocessed string
          strings[0] = str[last_i...strlen]
          endl = true
        # + segment width smaller than line width, continue
        elsif cur_width + width < line_width
          cur_width += width + space_width
          line += strings.shift + ' '
          endl = true if strings.size == 0
        # + segment width over the line width, process end of line
        else
          endl = true
        end
        
        if endl
          wraped_text.push(line)
          line = ""
          cur_width = PaddingWidth
        end
      end
      sample_bitmap.dispose if using_sample
      return wraped_text
    end # textwrap
  end # Kernel
  #=============================================================================
  # ** Object that includes in module will block some method access
  #=============================================================================
  module SecureObject
    #--------------------------------------------------------------------------
    def block_insure_action(msg)
      begin
        raise SecurityError, "Insecure operation: #{msg}"
      rescue Exception => err
        ::CRDE::Kernel::report_exception(err)
      end
    end
    #--------------------------------------------------------------------------
    def send(*args)
      block_insure_action(:send)
    end
    #--------------------------------------------------------------------------
    def method(*args)
      block_insure_action(:method)
    end
    #--------------------------------------------------------------------------
    def singleton_method(*args)
      block_insure_action(:singleton_method)
    end
    #--------------------------------------------------------------------------
    def instance_eval(*args)
      block_insure_action(:instance_eval)
    end
    #--------------------------------------------------------------------------
  end
  #--------------------------------------------------------------------------
  module Kernel
    include SecureObject if Config::SecureMode
    #--------------------------------------------------------------------------
    # * Ruby Constants
    #--------------------------------------------------------------------------
    RUBY_Qfalse = 0
    RUBY_Qtrue  = 2
    RUBY_Qnil   = 4
    RUBY_Qundef = 6
    RUBY_IMMEDIATE_MASK = 0x03
    RUBY_FIXNUM_FLAG    = 0x01
    RUBY_SYMBOL_FLAG    = 0x0e
    RUBY_SPECIAL_SHIFT  = 8
    #--------------------------------------------------------------------------
    class << self
    #--------------------------------------------------------------------------
    # * Convery address back to object
    #--------------------------------------------------------------------------
    def VALUE2obj(address)
      return ObjectSpace._id2ref(address >> 1)
    end
    #--------------------------------------------------------------------------
    # * Convert address back to Symbol
    #--------------------------------------------------------------------------
    def ID2SYM(address)
      return ObjectSpace._id2ref(address >> RUBY_SPECIAL_SHIFT)
    end
    #--------------------------------------------------------------------------
    end # class << self
    #--------------------------------------------------------------------------
  end # Kernel
  #=============================================================================
  # * Error Messages
  #=============================================================================
  module Errno
    include SecureObject if Config::SecureMode
    #--------------------------------------------------------------------------
    @raised = false
    @error_queue = []
    CRDE_Errno = Struct.new(:symbol, :callback, :err_args, :cb_args, :ex_info, :caller)
    RaiseMethod = method(:raise)
    #--------------------------------------------------------------------------
    # * Table of corresponding errors to message
    #--------------------------------------------------------------------------
    SymTable = {
      :type_error         => "Expected %s, received %s\n",
      :secure_hash_failed => "Security hash match failed:\n",
      :config_error       => "Script configuration error:\n",
      :file_missing       => "Cannot load such missing file:\n",
      :data_overflow      => "%s Overflow\n",
      :argument_error     => "Expected %s, received %d\n",
      :dependency_error   => "Dependency file `%s` not found for script `%s`, please make sure you have the script installed and placed in correct order\n",
    }
    #--------------------------------------------------------------------------
    class << self
      include SecureObject if Config::SecureMode
    #--------------------------------------------------------------------------
    # * Add an error to queue
    #   Params:
    #   symbol:: The error symbol
    #   callback:: The [Method] to call after the error is raised
    #   args::
    #     [-1]:: Extra message to display, must be string if present
    #     [0]:: Arguments for the errno function, should be undef/nil/array
    #     [1]:: Arguments for the callback function, should be undef/nil/array
    #   example:
    #   +rasie(:type_error, nil, [exptected.class, received.class])+
    #   +rasie(:data_overflow, :exit, "Int32")+
    #   +rasie(:file_missing, :puts, ["Kernel.rb", "foo.rb"], ["puts arg1", "puts arg2"])+
    #   +rasie(:secure_hash_failed, :exit, "You dirty hacker")+
    #--------------------------------------------------------------------------
    def raise_error(symbol, callback=nil, *args)
      ex_info  = args.pop if args.last.is_a?(String)
      err_args = cb_args = nil
      case args.length
      when 1
        err_args = args[0]
      when 2
        err_args, cb_args = args[0], args[1]
      end
      @error_queue << CRDE_Errno.new(symbol, callback, err_args, cb_args, ex_info || '', caller)
      start_raise
    end
    #--------------------------------------------------------------------------
    def start_raise
      while !@error_queue.empty?
        begin
          err = @error_queue.shift
          _raise_error(err)
          execute_callback(err)
        rescue Exception => error
          error_txt = ::CRDE::Kernel.report_exception(error, err.caller)
          print "Submit the file \"ErrorLog.txt\" in your project folder to the upper most script creators noted in the message.\n"
          msgbox("An error has occurred during the game.\nPlease submit the file \"ErrorLog.txt\" in your game folder to the developer in order to fix the bug.\n")
          filename = "ErrorLog.txt"
          File.open(filename, 'w+') {|f| f.write(error_txt + "\n") }
          raise  error.class, error.message, [error.backtrace.first]
        end
      end
    end
    #--------------------------------------------------------------------------
    def execute_callback(err)
      _execute_callback(err.callback, err.cb_args)
    end
    #--------------------------------------------------------------------------
    # * Check the arguments whether is OK
    #   Params:
    #   exp_num:: Valid argments count
    #   args:: An [Array] that contains the args to be checked
    #   cond:: A [Proc] to determine whether the argument is OK, default is
    #          to check whether is nil
    #   Alias:
    #   check_argument, check_arg, check_args
    #--------------------------------------------------------------------------
    def check_arguments(exp_num, args, cond=nil)
      cond = Proc.new{|n| !n.nil?} if cond.nil?
      return exp_num == args.select{|n| cond.call(n)}.size
    end
    alias :check_argument :check_arguments
    alias :check_arg :check_arguments
    alias :check_args :check_arguments
    #--------------------------------------------------------------------------
    private
    #--------------------------------------------------------------------------
    def _execute_callback(_method, args)
      _method.call(*args)
    end
    #--------------------------------------------------------------------------
    def _raise_error(err)
      msg  = SymTable[err.symbol] || '' + err.ex_info
      args = (err.err_args || []) << msg
      raise_method = nil
      case err.symbol
      when :dependency_error
        _dependency_error(*args)
      when :type_error
        _type_error(*args)
      when :argument_error
        _argument_error(*args)
        raise_method = self.method(:_argument_error)
      when :data_overflow
        _overflow_error(*args)
      when :secure_hash_failed
        args = [SecurityError, msg]
        _standard_error(*args)
      when :file_missing, :config_error
        args = [LoadError, msg]
        _standard_error(*args)
      else
        raise RuntimeError, "Unknown errno symbol: #{msg}"
      end
    end
    #--------------------------------------------------------------------------
    # * Raise a type error
    #   Params:
    #   exp:: Expected class name
    #   rec:: Received class name
    #   msg:: Message to display (this arg is passed automatically)
    #--------------------------------------------------------------------------
    def _type_error(exp, rec, msg)
      raise TypeError, sprintf(msg, exp, rec)
    end
    #--------------------------------------------------------------------------
    # * Raise when depdency script is missing
    #   Params:
    #   req:: The required depedecny script
    #   src:: Source script that require the depdency file
    #   msg:: Message to display (this arg is passed automatically)
    #--------------------------------------------------------------------------
    def _dependency_error(req, src, msg)
      raise LoadError, sprintf(msg, req, src)
    end
    #--------------------------------------------------------------------------
    # * Raise when argument is something wrong
    #   Params:
    #   exp:: Number of expected arguments, could be an array
    #   rec:: Number of received arguments
    #   msg:: Message to display (this arg is passed automatically)
    #--------------------------------------------------------------------------
    def _argument_error(exp, rec, msg)
      exp = exp.join(" or ") if exp.is_a?(Array)
      raise ArgumentError, sprintf(msg, exp, rec)
    end
    #--------------------------------------------------------------------------
    # * Raise when numeric out of valid range
    #   Params:
    #   type:: Type/class of data
    #--------------------------------------------------------------------------
    def _overflow_error(type, msg)
      raise ArgumentError, sprintf(msg, type)
    end
    #--------------------------------------------------------------------------
    def _standard_error(errno, msg)
      raise errno, msg
    end
    end # eigen class
  end # Errno
  #=============================================================================
  # * APIs
  #=============================================================================
  module Kernel::API
    ClipCursor           = Win32API.new('user32', 'ClipCursor', 'p', 'l')
    CloseWindow          = Win32API.new('user32', 'CloseWindow', 'l', 'l')
    CreateWindowEx       = Win32API.new('user32', 'CreateWindowEx', 'lppliiiipppp', 'l')
    DispatchMessage      = Win32API.new('user32', 'DispatchMessage', 'p', 'p')
    FindWindow           = Win32API.new('user32', 'FindWindow', 'pp', 'i')
    FindWindowEX         = Win32API.new('user32', 'FindWindowEx', 'llpp', 'i')
    GetAsyncKeyState     = Win32API.new("user32", "GetAsyncKeyState", 'i', 'i')
    GetClientRect        = Win32API.new('user32', 'GetClientRect', 'lp', 'i')
    GetClipboardData     = Win32API.new("user32","GetClipboardData", 'i', 'i')
    GetCursorPos         = Win32API.new('user32', 'GetCursorPos', 'p', 'i')
    GetFocus             = Win32API.new('user32', 'GetFocus', 'i', 'l')
    GetForegroundWindow  = Win32API.new('user32','GetForegroundWindow', 'v', 'l')
    GetKeyState          = Win32API.new("user32","GetKeyState", 'i', 'i')
    GetMessage           = Win32API.new('user32', 'GetMessage', 'plll', 'l')
    GetModuleHandle      = Win32API.new('kernel32', 'GetModuleHandle', 'p', 'l')
    GetPPString          = Win32API.new('kernel32', 'GetPrivateProfileString', 'pppplp', 'l')
    GetSystemMetrics     = Win32API.new('user32', 'GetSystemMetrics', 'i', 'i')
    GetWindowRect        = Win32API.new('user32', 'GetWindowRect', 'lp', 'i')
    GetWindowText        = Win32API.new('user32', 'GetWindowText', 'lpi', 'i')
    GetWindowTextLength  = Win32API.new("user32", "GetWindowTextLength", "l", "l")
    IsWindow             = Win32API.new('user32', 'IsWindow', 'l', 'i')
    ScreenToClient       = Win32API.new('user32', 'ScreenToClient', 'lp', 'i')
    SetCursorPos         = Win32API.new('user32', 'SetCursorPos', 'nn', 'n')
    SetFocus             = Win32API.new('user32', "SetFocus", 'l', 'l')
    SetParent            = Win32API.new('user32', 'SetParent', 'll', 'l')
    SetWindowPos         = Win32API.new('user32', 'SetWindowPos', 'liiiiip', 'i')
    SetWindowText        = Win32API.new('user32', 'SetWindowText', 'lp', 'l')
    SendMessage          = Win32API.new('user32', 'SendMessage', 'llll', 'l')
    ShowWindow           = Win32API.new('user32', "ShowWindow", "ll", "l")
    UpdateWindow         = Win32API.new('user32', 'UpdateWindow', 'l', 'l')
    WcharToMulByte       = Win32API.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'p')
    WritePPString        = Win32API.new('kernel32', 'WritePrivateProfileString', 'pppp', 'i')
  end # API
  #=============================================================================
  # * Module that related to RMVA build-in RPG stuff
  #=============================================================================
  module RPG
  #=============================================================================
  # * Feature constants form BattlerBase for includes
  #=============================================================================
  module Features
    FEATURE_ELEMENT_RATE    =   Game_BattlerBase::FEATURE_ELEMENT_RATE    # Element Rate
    FEATURE_DEBUFF_RATE     =   Game_BattlerBase::FEATURE_DEBUFF_RATE     # Debuff Rate
    FEATURE_STATE_RATE      =   Game_BattlerBase::FEATURE_STATE_RATE      # State Rate
    FEATURE_STATE_RESIST    =   Game_BattlerBase::FEATURE_STATE_RESIST    # State Resist
    FEATURE_PARAM           =   Game_BattlerBase::FEATURE_PARAM           # Parameter
    FEATURE_XPARAM          =   Game_BattlerBase::FEATURE_XPARAM          # Ex-Parameter
    FEATURE_SPARAM          =   Game_BattlerBase::FEATURE_SPARAM          # Sp-Parameter
    FEATURE_ATK_ELEMENT     =   Game_BattlerBase::FEATURE_ATK_ELEMENT     # Atk Element
    FEATURE_ATK_STATE       =   Game_BattlerBase::FEATURE_ATK_STATE       # Atk State
    FEATURE_ATK_SPEED       =   Game_BattlerBase::FEATURE_ATK_SPEED       # Atk Speed
    FEATURE_ATK_TIMES       =   Game_BattlerBase::FEATURE_ATK_TIMES       # Atk Times+
    FEATURE_STYPE_ADD       =   Game_BattlerBase::FEATURE_STYPE_ADD       # Add Skill Type
    FEATURE_STYPE_SEAL      =   Game_BattlerBase::FEATURE_STYPE_SEAL      # Disable Skill Type
    FEATURE_SKILL_ADD       =   Game_BattlerBase::FEATURE_SKILL_ADD       # Add Skill
    FEATURE_SKILL_SEAL      =   Game_BattlerBase::FEATURE_SKILL_SEAL      # Disable Skill
    FEATURE_EQUIP_WTYPE     =   Game_BattlerBase::FEATURE_EQUIP_WTYPE     # Equip Weapon
    FEATURE_EQUIP_ATYPE     =   Game_BattlerBase::FEATURE_EQUIP_ATYPE     # Equip Armor
    FEATURE_EQUIP_FIX       =   Game_BattlerBase::FEATURE_EQUIP_FIX       # Lock Equip
    FEATURE_EQUIP_SEAL      =   Game_BattlerBase::FEATURE_EQUIP_SEAL      # Seal Equip
    FEATURE_SLOT_TYPE       =   Game_BattlerBase::FEATURE_SLOT_TYPE       # Slot Type
    FEATURE_ACTION_PLUS     =   Game_BattlerBase::FEATURE_ACTION_PLUS     # Action Times+
    FEATURE_SPECIAL_FLAG    =   Game_BattlerBase::FEATURE_SPECIAL_FLAG    # Special Flag
    FEATURE_COLLAPSE_TYPE   =   Game_BattlerBase::FEATURE_COLLAPSE_TYPE   # Collapse Effect
    FEATURE_PARTY_ABILITY   =   Game_BattlerBase::FEATURE_PARTY_ABILITY   # Party Ability
    # ---Feature Flags---
    FLAG_ID_AUTO_BATTLE     =   Game_BattlerBase::FLAG_ID_AUTO_BATTLE     # auto battle
    FLAG_ID_GUARD           =   Game_BattlerBase::FLAG_ID_GUARD           # guard
    FLAG_ID_SUBSTITUTE      =   Game_BattlerBase::FLAG_ID_SUBSTITUTE      # substitute
    FLAG_ID_PRESERVE_TP     =   Game_BattlerBase::FLAG_ID_PRESERVE_TP     # preserve TP
  end # Features
  end # RPG
end
#===============================================================================
# * Basic Object
#===============================================================================
class Object
  #------------------------------------------------------------------------
  alias :ruby_class :class # Alias for class prevent misuse of Game_Actor
  #------------------------------------------------------------------------
  def eigenclass
    class << self
      return self
    end
  end
  #------------------------------------------------------------------------
  # * Set hashid
  #------------------------------------------------------------------------
  def hash_self
    return (@hashid = self.hash)
  end
  #------------------------------------------------------------------------
  def hashid
    hash_self if @hashid.nil?
    return @hashid
  end
  #------------------------------------------------------------------------
  def to_bool
    return true
  end
  #------------------------------------------------------------------------
  # * Pointer address
  #------------------------------------------------------------------------
  def ptr
    object_id << 1
  end
end
#===============================================================================
# * True/Flase/Nil class
#===============================================================================
class TrueClass
  def to_i; return 1; end
  def ptr;  return CRDE::Kernel::RUBY_Qtrue; end 
end
#----------------------------------------------------------------------------
class FalseClass
  def to_i; return CRDE::Kernel::RUBY_Qfalse; end
end
#==========================================================================
class NilClass
  #----------------------------------------------------------------------------
  # *) Convert to boolean
  #----------------------------------------------------------------------------
  def to_bool; return false; end
  def ptr; return CRDE::Kernel::RUBY_Qnil; end
end
#==========================================================================
class Fixnum
  def ptr; object_id; end
end
#==========================================================================
class Symbol
  def ptr; object_id; end
end
#==========================================================================
# ** RPG::BaseItem
#==========================================================================
class RPG::BaseItem
  FEATURE_ACTION_PLUS   = 61              # Action Times+
  FEATURE_SPECIAL_FLAG  = 62              # Special Flag
  FEATURE_PARTY_ABILITY = 64              # Party Ability
  #--------------------------------------------------------------------------
  # * Get Feature Object Array (Feature Codes Limited)
  #--------------------------------------------------------------------------
  def features(code = nil)
    return @features if code.nil?
    @features.select {|ft| ft.code == code }
  end
  #--------------------------------------------------------------------------
  # * Get Feature Object Array (Feature Codes and Data IDs Limited)
  #--------------------------------------------------------------------------
  def features_with_id(code, id)
    @features.select {|ft| ft.code == code && ft.data_id == id }
  end
  #--------------------------------------------------------------------------
  # * Calculate Complement of Feature Values
  #--------------------------------------------------------------------------
  def features_pi(code, id)
    result = features_with_id(code, id).inject(1.0){ |r, ft|
      r *= (ft.value == 0.0) ? 0.0000001 : ft.value
    }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Feature Values (Specify Data ID)
  #--------------------------------------------------------------------------
  def features_sum(code, id)
    features_with_id(code, id).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # * Calculate Sum of Feature Values (Data ID Unspecified)
  #--------------------------------------------------------------------------
  def features_sum_all(code)
    features(code).inject(0.0) {|r, ft| r += ft.value }
  end
  #--------------------------------------------------------------------------
  # * Calculate Set Sum of Features
  #--------------------------------------------------------------------------
  def features_set(code)
    features(code).inject([]) {|r, ft| r |= [ft.data_id] }
  end
  #--------------------------------------------------------------------------
  # * Get Array of Additional Action Time Probabilities
  #--------------------------------------------------------------------------
  def action_plus_set
    features(FEATURE_ACTION_PLUS).collect {|ft| ft.value }
  end
  #--------------------------------------------------------------------------
  # * Determine if Special Flag
  #--------------------------------------------------------------------------
  def special_flag(flag_id)
    features(FEATURE_SPECIAL_FLAG).any? {|ft| ft.data_id == flag_id }
  end
  #--------------------------------------------------------------------------
  # * Determine Party Ability
  #--------------------------------------------------------------------------
  def party_ability(ability_id)
    features(FEATURE_PARTY_ABILITY).any? {|ft| ft.data_id == ability_id }
  end
  #--------------------------------------------------------------------------
end
#==============================================================================
# ** RPG::EquipItem
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
  #---------------------------------------------------------------------------
  def param(id)
    return @params[id]
  end
  #---------------------------------------------------------------------------
end
#==============================================================================
# ** Sprite
#==============================================================================
class Sprite
  #---------------------------------------------------------------------------
  def show
    self.visible = true
    self
  end
  #---------------------------------------------------------------------------
  def hide
    self.visible = false
    self
  end
  #---------------------------------------------------------------------------
  def visible?
    return self.visible
  end
  #---------------------------------------------------------------------------
end
#===============================================================================
# ** DataManager
#===============================================================================
module DataManager
  include CRDE::SecureObject if CRDE::Config::SecureMode
  #------------------------------------------------------------------------
  # * Listener list when loading note tag of RPG objects
  @notetag_listeners = {
    RPG::BaseItem   => [],
    RPG::UsableItem => [],
    RPG::EquipItem  => [],
    RPG::Actor      => [],
    RPG::Class      => [],
    RPG::Skill      => [],
    RPG::Item       => [],
    RPG::Weapon     => [],
    RPG::Armor      => [],
    RPG::State      => [],
    RPG::Enemy      => [],
    RPG::Event      => [],
    RPG::Map        => []
  }
  #------------------------------------------------------------------------
  NotetagLoadListener = Struct.new(:klass, :proc)
  #------------------------------------------------------------------------
  class << self
  include CRDE::SecureObject if CRDE::Config::SecureMode
  #------------------------------------------------------------------------
  alias load_database_crde load_database
  def load_database
    load_database_crde
    load_notetags_crde
  end
  #------------------------------------------------------------------------
  # * Register listener when iterating through each items
  #   klass:: Listener of the RPG class
  #   proc:: Proc/Method to do the processing, argument is the RPG object
  #   Example:
  #   +(RPG::Weapon, Proc.new{|obj| puts "Weapon note: #{obj.note}"})+
  #------------------------------------------------------------------------
  def register_notetag_listener(klass, proc)
    if klass.is_a?(Symbol)
      case klass.to_s.downcase.to_sym
      when :baseitem;   klass = ::RPG::BaseItem;
      when :usableitem; klass = ::RPG::UsableItem;
      when :equipitem;  klass = ::RPG::EquipItem;
      when :actor;      klass = ::RPG::Actor;
      when :skill;      klass = ::RPG::Skill;
      when :item;       klass = ::RPG::Item;
      when :weapon;     klass = ::RPG::Weapon;
      when :armor;      klass = ::RPG::Armor;
      when :state;      klass = ::RPG::State;
      when :map;        klass = ::RPG::Map;
      when :enemy;      klass = ::RPG::Enemy;
      when :class;      klass = ::RPG::Class;
      when :event;      klass = ::RPG::Event;
      end
    end
    @notetag_listeners[klass].push(NotetagLoadListener.new(klass, proc))
  end
  #------------------------------------------------------------------------
  def load_notetags_crde
    groups = [$data_actors, $data_classes, $data_skills, $data_items,
    $data_weapons, $data_armors, $data_enemies, $data_states]
    
    groups.each do |group|
      @notetag_listeners.each do |listener_class, listeners|
        next unless group[1].is_a?(listener_class)
        load_group_notetag(group, listeners)
      end
    end
  end
  #------------------------------------------------------------------------
  def load_group_notetag(group, listeners)
    group.each do |obj|
      next unless obj
      listeners.each do |listener|
        listener.proc.call(obj)
      end
    end
  end
  #------------------------------------------------------------------------
  end # eigenclass
  #------------------------------------------------------------------------
end
#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base < Window
  #---------------------------------------------------------------------------
  def active?
    return self.active
  end
  #---------------------------------------------------------------------------
  def visible?
    return self.visible
  end
  #---------------------------------------------------------------------------
end
#==============================================================================
# ** Game_BattlerBase
#==============================================================================
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Overwrite: dirty hack to avoid divided by zero error
  #--------------------------------------------------------------------------
  def features_pi(code, id)
    features_with_id(code, id).inject(1.0) {|r, ft|
      r *= (ft.value == 0.0) ? 0.0000001 : ft.value
    }
  end
end
