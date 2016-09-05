

CyrodiilAction = CyrodiilAction or {}

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
CyrodiilAction.defaults.timeBeforeBattleClear = 180
CyrodiilAction.defaults.underAttack = "/esoui/art/mappins/ava_attackburst_64.dds"
CyrodiilAction.defaults.transparentColor = colors.invisible
CyrodiilAction.defaults.alliance = {}
CyrodiilAction.defaults.alliance[ALLIANCE_NONE] = {}
CyrodiilAction.defaults.alliance[ALLIANCE_NONE].color = colors.white
CyrodiilAction.defaults.alliance[AD] = {}
CyrodiilAction.defaults.alliance[AD].color = colors.yellow
CyrodiilAction.defaults.alliance[AD].flag = "/esoui/art/ava/ava_allianceflag_aldmeri.dds"
CyrodiilAction.defaults.alliance[DC] = {}
CyrodiilAction.defaults.alliance[DC].color = colors.blue
CyrodiilAction.defaults.alliance[DC].flag = "/esoui/art/ava/ava_allianceflag_daggerfall.dds"
CyrodiilAction.defaults.alliance[EP] = {}
CyrodiilAction.defaults.alliance[EP].color = colors.red
CyrodiilAction.defaults.alliance[EP].flag = "/esoui/art/ava/ava_allianceflag_ebonheart.dds"
CyrodiilAction.defaults.noIcon = ""
CyrodiilAction.defaults.icons = {}
CyrodiilAction.defaults.icons.keep = {}
CyrodiilAction.defaults.icons.keep[KEEPTYPE_KEEP] = "/esoui/art/mappins/ava_largekeep_neutral.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_OUTPOST] = "/esoui/art/mappins/ava_outpost_neutral.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_IMPERIAL_CITY_DISTRICT] = "/esoui/art/mappins/ava_imperialdistrict_neutral.dds"
CyrodiilAction.defaults.icons.keep[KEEPTYPE_TOWN] = "/esoui/art/mappins/ava_town_neutral.dds"
CyrodiilAction.defaults.icons.keep.resource = {}
CyrodiilAction.defaults.icons.keep.resource[RESOURCETYPE_FOOD] = "/esoui/art/mappins/ava_farm_neutral.dds"
CyrodiilAction.defaults.icons.keep.resource[RESOURCETYPE_ORE] = "/esoui/art/mappins/ava_mine_neutral.dds"
CyrodiilAction.defaults.icons.keep.resource[RESOURCETYPE_WOOD] = "/esoui/art/mappins/ava_lumbermill_neutral.dds"

--/esoui/art/campaign/overview_scrollicon_aldmeri.dds
--/esoui/art/campaign/overview_scrollicon_daggefall.dds
--/esoui/art/campaign/overview_scrollicon_ebonheart.dds
