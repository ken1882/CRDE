#=============================================================================#
#   CRDE - Kernel                                                             #
#   Version: 0.1.0                                                            #  
#   Author: Compeador                                                         #  
#   Last update: 2019.05.02                                                   #  
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
  module Kernel
    # Nothing to add
  end
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
  end
  #=============================================================================
  # * Feature constants form BattlerBase for includes
  #=============================================================================
  module Kernel::Features
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
  end
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