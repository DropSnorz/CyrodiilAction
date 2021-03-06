﻿CyrodiilAction = CyrodiilAction or {}

local AD = ALLIANCE_ALDMERI_DOMINION
local DC = ALLIANCE_DAGGERFALL_COVENANT
local EP = ALLIANCE_EBONHEART_PACT

CyrodiilAction.ACTION_ATTACK = 1
CyrodiilAction.ACTION_DEFEND = 2

CyrodiilAction.colors = {}
local colors = CyrodiilAction.colors
--Transparent BG colors
CyrodiilAction.colors.blackTrans = ZO_ColorDef:New(0, 0, 0, .3)
CyrodiilAction.colors.greenTrans = ZO_ColorDef:New(.2, .5, .2, .6)
CyrodiilAction.colors.greyTrans = ZO_ColorDef:New(.5, .5, .5, .3)
CyrodiilAction.colors.invisible = ZO_ColorDef:New(0,0,0,0)
CyrodiilAction.colors.redTrans = ZO_ColorDef:New(.5, 0, 0, .3)
CyrodiilAction.colors.blue = ZO_ColorDef:New(.408, .560, .698, 1)
CyrodiilAction.colors.green = ZO_ColorDef:New(.6222, .7, .4532, 1)
CyrodiilAction.colors.orange = ZO_ColorDef:New(.9, .65, .3, 1)
CyrodiilAction.colors.purple = ZO_ColorDef:New(.7, .4, .73, 1)
CyrodiilAction.colors.red = ZO_ColorDef:New(.871, .361, .310, 1)
CyrodiilAction.colors.white = ZO_ColorDef:New(.8, .8, .8, 1)
CyrodiilAction.colors.yellow = ZO_ColorDef:New(.765, .667, .290, 1)

CyrodiilAction.defaults = {}
CyrodiilAction.defaults.timeBeforeBattleClear = 120
CyrodiilAction.defaults.timeBeforeResourceBattleClear = 80
CyrodiilAction.defaults.underAttack = "esoui/art/mappins/ava_attackburst_64.dds"
CyrodiilAction.defaults.transparentColor = colors.invisible
CyrodiilAction.defaults.alliance = {}
CyrodiilAction.defaults.alliance[ALLIANCE_NONE] = {}
CyrodiilAction.defaults.alliance[ALLIANCE_NONE].color = colors.white
CyrodiilAction.defaults.alliance[AD] = {}
CyrodiilAction.defaults.alliance[AD].color = GetAllianceColor(ALLIANCE_ALDMERI_DOMINION)
CyrodiilAction.defaults.alliance[AD].flag = "esoui/art/ava/ava_allianceflag_aldmeri.dds"
CyrodiilAction.defaults.alliance[AD].pin = "esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds"
CyrodiilAction.defaults.alliance[DC] = {}
CyrodiilAction.defaults.alliance[DC].color = GetAllianceColor(ALLIANCE_DAGGERFALL_COVENANT)
CyrodiilAction.defaults.alliance[DC].flag = "esoui/art/ava/ava_allianceflag_daggerfall.dds"
CyrodiilAction.defaults.alliance[DC].pin = "esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds"
CyrodiilAction.defaults.alliance[EP] = {}
CyrodiilAction.defaults.alliance[EP].color = GetAllianceColor(ALLIANCE_EBONHEART_PACT)
CyrodiilAction.defaults.alliance[EP].flag = "esoui/art/ava/ava_allianceflag_ebonheart.dds"
CyrodiilAction.defaults.alliance[EP].pin = "esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds"
CyrodiilAction.defaults.noIcon = ""
CyrodiilAction.defaults.icons = {}
CyrodiilAction.defaults.icons.actionDefend = "esoui/art/lfg/lfg_normaldungeon_down.dds"
CyrodiilAction.defaults.icons.actionAttack = "esoui/art/campaign/campaignbrowser_indexicon_normal_down.dds"
CyrodiilAction.defaults.icons.keep = {}
CyrodiilAction.defaults.icons.keep[KEEPTYPE_KEEP] = "esoui/art/mappins/ava_largekeep_neutral.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_OUTPOST] = "esoui/art/mappins/ava_outpost_neutral.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_IMPERIAL_CITY_DISTRICT] = "esoui/art/mappins/ava_imperialdistrict_neutral.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_TOWN] = "esoui/art/mappins/ava_town_neutral.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_BRIDGE] = "esoui/art/mappins/ava_bridge_passable.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_MILEGATE] = "esoui/art/mappins/ava_milegate_passable.dds"
CyrodiilAction.defaults.icons.keep.resource = {}
CyrodiilAction.defaults.icons.keep.resource[RESOURCETYPE_FOOD] = "esoui/art/mappins/ava_farm_neutral.dds"
CyrodiilAction.defaults.icons.keep.resource[RESOURCETYPE_ORE] = "esoui/art/mappins/ava_mine_neutral.dds"
CyrodiilAction.defaults.icons.keep.resource[RESOURCETYPE_WOOD] = "esoui/art/mappins/ava_lumbermill_neutral.dds"
CyrodiilAction.defaults.icons.keep.bridge = {}
CyrodiilAction.defaults.icons.keep.bridge["PASSABLE"] = "esoui/art/mappins/ava_bridge_passable.dds"
CyrodiilAction.defaults.icons.keep.bridge["NOT_PASSABLE"] = "esoui/art/mappins/ava_bridge_not_passable.dds"
CyrodiilAction.defaults.icons.keep.milegate = {}
CyrodiilAction.defaults.icons.keep.milegate["PASSABLE"] = "esoui/art/mappins/ava_milegate_passable.dds"
CyrodiilAction.defaults.icons.keep.milegate["NOT_PASSABLE"] = "esoui/art/mappins/ava_milegate_not_passable.dds"

CyrodiilAction.defaults.icons.ava = {}
CyrodiilAction.defaults.icons.ava.keep = {}
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_KEEP] = {}
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_KEEP][AD] = "esoui/art/mappins/ava_largekeep_aldmeri.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_KEEP][DC] = "esoui/art/mappins/ava_largekeep_daggerfall.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_KEEP][EP] = "esoui/art/mappins/ava_largekeep_ebonheart.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_OUTPOST] = {}
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_OUTPOST][AD] = "esoui/art/mappins/ava_outpost_aldmeri.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_OUTPOST][DC] = "esoui/art/mappins/ava_outpost_daggerfall.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_OUTPOST][EP] = "esoui/art/mappins/ava_outpost_ebonheart.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_IMPERIAL_CITY_DISTRICT] = {}
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_IMPERIAL_CITY_DISTRICT][AD] = "esoui/art/mappins/ava_imperialdistrict_aldmeri.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_IMPERIAL_CITY_DISTRICT][DC] = "esoui/art/mappins/ava_imperialdistrict_daggerfall.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_IMPERIAL_CITY_DISTRICT][EP] = "esoui/art/mappins/ava_imperialdistrict_ebonheart.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_TOWN] = {}
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_TOWN][AD] = "esoui/art/mappins/ava_town_aldmeri.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_TOWN][DC] = "esoui/art/mappins/ava_town_daggerfall.dds"
CyrodiilAction.defaults.icons.ava.keep[KEEPTYPE_TOWN][EP] = "esoui/art/mappins/ava_town_ebonheart.dds"
CyrodiilAction.defaults.icons.ava.keep.resource = {}
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_FOOD] = {}
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_FOOD][AD] = "esoui/art/mappins/ava_farm_aldmeri.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_FOOD][DC] = "esoui/art/mappins/ava_farm_daggerfall.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_FOOD][EP] = "esoui/art/mappins/ava_farm_ebonheart.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_ORE] = {}
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_ORE][AD] = "esoui/art/mappins/ava_mine_aldmeri.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_ORE][DC] = "esoui/art/mappins/ava_mine_daggerfall.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_ORE][EP] = "esoui/art/mappins/ava_mine_ebonheart.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_WOOD] = {}
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_WOOD][AD] = "esoui/art/mappins/ava_lumbermill_aldmeri.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_WOOD][DC] = "esoui/art/mappins/ava_lumbermill_daggerfall.dds"
CyrodiilAction.defaults.icons.ava.keep.resource[RESOURCETYPE_WOOD][EP] = "esoui/art/mappins/ava_lumbermill_ebonheart.dds"

--/esoui/art/campaign/overview_scrollicon_aldmeri.dds
--/esoui/art/campaign/overview_scrollicon_daggefall.dds
--/esoui/art/campaign/overview_scrollicon_ebonheart.dds
