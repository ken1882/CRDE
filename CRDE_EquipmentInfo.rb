#=============================================================================#
#   CRDE - Equipment Info                                                     #
#   Version: 1.0.3                                                            #  
#   Author: Compeador                                                         #  
#   Last update: 2021.09.07                                                   #  
#=============================================================================#
$imported = {} if $imported.nil?
$imported[:CRDE_EQInfo] = true
#=============================================================================#
#                               ** Update log **                              #
#-----------------------------------------------------------------------------#
#                                                                             #
# -- 2021.09.07: Add more inverse color and no color option for equips        #
# -- 2019.05.06: Start the script and completed                               #
#                                                                             #
#=============================================================================#
#                              ** User Manual **                              #
#-----------------------------------------------------------------------------#
# > Introduction:                                                             #
#       This script defines configs for other CRDE equipment related script.  #
#=============================================================================#
#                            ** Compatibility **                              #
#-----------------------------------------------------------------------------#
#   > CRDE Kernel is required                                                 #
#   > Support information of 'Equipment Set Bonuses' by Modern Algebra        #
#                                                                             #
#       ** Place this script below the scripts mentioned above **             #
#                                                                             #
#=============================================================================#

if !$imported[:CRDE_Kernel]
  raise LoadError, "CRDE Kernel is required for Equipemnt Info script"
end

module CRDE
  #=============================================================================
  # * Module that related to equip info
  #=============================================================================
  module RPG::EquipInfo
    include CRDE::RPG::Features
    #---------------------------------------------------------------------
    # * Id for standard param, chances are no need to edits
    FeatureNormalParam = -1
    #---------------------------------------------------------------------
    # * The param name table
    ParamNameTable = {        
      #    better not touch      edit the text for your need
      #    ↓              ↓                 ↓       
      # symbol        => [id,  display group text showed in comparison]
      :param          => [FeatureNormalParam, ''],                  # Basic parameter
      :xparam         => [FEATURE_XPARAM, ''],                      # Ex-Parameter
      :sparam         => [FEATURE_SPARAM, ''],                      # Sp-Parameter
      :param_rate     => [FEATURE_PARAM, 'Param multipler'],        # Parameter
      :special_flag   => [FEATURE_SPECIAL_FLAG, 'Special'],         # Special feature flag
      :element_rate   => [FEATURE_ELEMENT_RATE, 'Element Rate'],    # Element Rate
      :debuff_rate    => [FEATURE_DEBUFF_RATE, 'Debuff Rate'],      # Debuff Rate
      :state_rate     => [FEATURE_STATE_RATE, 'State Rate'],        # State Rate
      :state_resist   => [FEATURE_STATE_RESIST, 'State Resist'],    # State Resist
      :atk_element    => [FEATURE_ATK_ELEMENT, 'Atk Element'],      # Atk Element
      :atk_state      => [FEATURE_ATK_STATE, 'Atk State'],          # Atk State
      :atk_speed      => [FEATURE_ATK_SPEED, 'Feature'],            # Atk Speed
      :atk_times      => [FEATURE_ATK_TIMES, 'Feature'],            # Atk Times+
      :stype_add      => [FEATURE_STYPE_ADD, 'Add Skill Type'],     # Add Skill Type
      :stype_seal     => [FEATURE_STYPE_SEAL, 'Disable Skill Type'],# Disable Skill Type
      :skill_add      => [FEATURE_SKILL_ADD, 'Add Skill'],          # Add Skill
      :skill_seal     => [FEATURE_SKILL_SEAL, 'Disable Skill'],     # Disable Skill
      :equip_wtype    => [FEATURE_EQUIP_WTYPE, 'Equip Weapon'],     # Equip Weapon
      :equip_atype    => [FEATURE_EQUIP_ATYPE, 'Equip Armor'],      # Equip Armor
      :equip_fix      => [FEATURE_EQUIP_FIX, 'Lock Equip'],         # Lock Equip
      :equip_seal     => [FEATURE_EQUIP_SEAL, 'Seal Equip'],        # Seal Equip
      :action_plus    => [FEATURE_ACTION_PLUS, 'Action Times+'],    # Action Times+
      :party_ability  => [FEATURE_PARTY_ABILITY, 'Party ability'],  # Party ability
    }
    
    #---------------------------------------------------------------------
    # * Id for equipment set, perhaps not necessary to change
    FeatureEquipSet = -2
    #---------------------------------------------------------------------
    # * Compare with MA's equipment set diff
    if $imported[:MA_EquipmentSetBonuses]
      # Text displayed when showing the comparison of set equipment bonus
      SetEquipmentTextStem = "Set bonus"
      SetEquipmentText = SetEquipmentTextStem + " [%s]:" # don't edit this
      ParamNameTable[:equipset_plus] = [FeatureEquipSet, SetEquipmentText]
    end
    #---------------------------------------------------------------------
    MISC_text = 'Other' # the group text not in this order list
    #---------------------------------------------------------------------
    # * Display order of comparison group text, upper one displayed first
    TextDisplayOrder = [
      '',         # suggestion: better not touch this line
      'Feature',
      'Special',
      'Param multipler',
      'Element Rate',
      'Debuff Rate',
      'State Rate',
      'State Resist',
      'Atk Element',
      'Atk State',
      'Atk Speed',
      'Atk Times+',
      'Add Skill Type',
      'Disable Skill Type',
      'Add Skill',
      'Disable Skill',
      'Equip Weapon',
      'Equip Armor',
      'Lock Equip',
      'Seal Equip',
      'Slot Type',
      'Action Times+',
      'Party ability',
      MISC_text
    ]

    TextDisplayOrder.push(SetEquipmentText) if $imported[:MA_EquipmentSetBonuses]
    #---------------------------------------------------------------------
    # * Name display for each xparam
    XParamName = {
      0   => "HIT",  # HIT rate
      1   => "EVA",  # EVAsion rate
      2   => "CRI",  # CRItical rate
      3   => "CEV",  # Critical EVasion rate
      4   => "MEV",  # Magic EVasion rate
      5   => "MRF",  # Magic ReFlection rate
      6   => "CNT",  # CouNTer attack rate
      7   => "HRG",  # Hp ReGeneration rate
      8   => "MRG",  # Mp ReGeneration rate
      9   => "TRG",  # Tp ReGeneration rate
    }
    #---------------------------------------------------------------------
    # * Name display for each sparam
    SParamName = {
      0   => "TGR",  # TarGet Rate
      1   => "GRD",  # GuaRD effect rate
      2   => "REC",  # RECovery effect rate
      3   => "PHA",  # PHArmacology
      4   => "MCR",  # Mp Cost Rate
      5   => "TCR",  # Tp Charge Rate
      6   => "PDR",  # Physical Damage Rate
      7   => "MDR",  # Magical Damage Rate
      8   => "FDR",  # Floor Damage Rate
      9   => "EXR",  # EXperience Rate
    }
    #---------------------------------------------------------------------
    # * Name display for party ability
    PartyAbilityName = {
      0   => "Encounter Half",          # halve encounters
      1   => "Encounter None",          # disable encounters
      2   => "Cancel Surprise",         # disable surprise
      3   => "Raise Preemptive",        # increase preemptive strike rate
      4   => "Gold Double",             # double money earned
      5   => "Item Drop Rate Double",   # double item acquisition rate
    }
    #---------------------------------------------------------------------
    # * Name display for special feature
    SpecialFeatureName = {
      0 => "Auto Battle",
      1 => "Guard",
      2 => "Substitute",
      3 => "Preserve TP",
    }
    #--------------------------------------------------------------------------
    # * Text displayed when two equipments have no difference:
    NoDiffText = "No Difference"
    #--------------------------------------------------------------------------
    # * Feature name displayed at first of the line, before value comparison
    OtherFeatureName = {
      # feature id        => display name
      FEATURE_ATK_SPEED   => 'ASP',
      FEATURE_ATK_TIMES   => 'ATS+',
      FEATURE_ACTION_PLUS => '+%d:',
    }
    #---------------------------------------------------------------------
    # * prefix of single feature comparison
    FeatureAddText     = "+" + " %s"
    FeatureRemoveText  = "-" + " %s"
    FeatureEnableText  = "√" + " %s"
    FeatureDisableText = "X" + " %s"
    #---------------------------------------------------------------------
    # * The feature id that is actually not good
    InverseColorFeature = [
      FEATURE_STYPE_SEAL, FEATURE_SKILL_SEAL, FEATURE_EQUIP_FIX,
      FEATURE_EQUIP_SEAL, FEATURE_ELEMENT_RATE,
    ]
    #---------------------------------------------------------------------
    # * The feature id that either good nor bad (will not change color)
    NoColorFeature = [

    ]
    #---------------------------------------------------------------------
    # * The xparam that is actually not good
    InverseColorXParam = [
    ]
    #---------------------------------------------------------------------
    # * The sparam that is actually not good
    InverseColorSParam = [
      4, # MCR
      6, # PDR
      7, # MDR
      8, # FDR
    ]
    #---------------------------------------------------------------------
    # * Xparam that actually has no good or bad (will not change color)
    NoColorXParam = [
    ]
    #---------------------------------------------------------------------
    # * Sparam that actually has no good or bad (will not change color)
    NoColorSParam = [
      0 # TGR
    ]
    #---------------------------------------------------------------------
    # * The state id that is actually goos should inverse color
    #   because state resist and lower state rate are usually used 
    #   in debuff. (Lower chance to get debuff or restist debuff is green)
    #   So buff state id goes here.
    #   Or you can just add:
    #   <diff inverse color>
    #   in the state note tag box
    InverseColorStateID = [
      0, # example
    ]

    # Recommending add note in the skill instead
    InverseColorSkillID = []
    #---------------------------------------------------------------------
    # * The value of given feature id will disaply as percent
    PercentageFeaure = [
      FEATURE_ELEMENT_RATE, FEATURE_DEBUFF_RATE, FEATURE_STATE_RATE,
      FEATURE_PARAM, FEATURE_XPARAM, FEATURE_SPARAM, FEATURE_ATK_STATE,
      FEATURE_ACTION_PLUS,
    ]
    #=====================================================================#
    # Please don't edit anything below unless you know what you're doing! #
    #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#

    InverseColorRegex = /<diff(.?)inverse(.?)color>/i

    ::DataManager.register_notetag_listener(:state, Proc.new{|obj|
      obj.note.split(/[\r\n]+/).each do |line|
        InverseColorStateID.push(obj.id) if line =~ InverseColorRegex
      end
    })

    ::DataManager.register_notetag_listener(:skill, Proc.new{|obj|
      obj.note.split(/[\r\n]+/).each do |line|
        InverseColorSkillID.push(obj.id) if line =~ InverseColorRegex
      end
    })

    # Strcuture holds compare result of each difference
    DiffInfo = Struct.new(:feature_id, :data_id, :value, :display_str, :group_text)
    # :feature_id  > what do you expect me to say?
    # :data_id     > data id in grouped feature, such as param
    # :delta       > value changed of that feature, in certain feature id is:
    #   true/false = add/remove after equip
    #
    # :display_str > Other text displayed
    # :group_text  > even need to explain?

    # Uses to fill the small blanks where not proper to write more lines
    DummyInfo = DiffInfo.new(nil, nil, nil, '')
    #--------------------------------------------------------------------------
    # * Mapping table for easier query
    StringTable     = {}   # feature_id => group_text
    FeatureIdTable  = {}   # group_text => feature_id
    DisplayOrder    = {}   # group_text => order
    DisplayIdOrder  = {}   # feature_id => order
    ParamNameTable.each do |symbol, info|
      StringTable[info[0]] = info[1]
      FeatureIdTable[info[1]] = info[0]
    end
    TextDisplayOrder.each_with_index do |str, i|
      DisplayOrder[str] = i
      DisplayIdOrder[FeatureIdTable[str]] = i
    end
  end # RPG::EquipInfo
end # CRDE