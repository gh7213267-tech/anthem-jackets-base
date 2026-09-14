--*TU 1.4.1*--

local anthemJacket = {
	-- JACKETS
	}
	
	local function getAnthemJacketId(teamid,side, val)
		if (anthemJacket[teamid] ~= nil) and (anthemJacket[teamid][string.lower(side)] ~= nil) then
			return anthemJacket[teamid][side].id or val
		end
		return val
	end
	
	local function getAnthemJacketTextureVariation(teamid,side, val)
		if ((anthemJacket[teamid] ~= nil) and (anthemJacket[teamid][string.lower(side)] ~= nil)) then
			return anthemJacket[teamid][side].var or val
		end
		return val
	end

	local anthemPants = {
		-- PANTS
	}
	
	local function getAnthemPantsId(teamid,side, val)
		if (anthemPants[teamid] ~= nil) and (anthemPants[teamid][string.lower(side)] ~= nil) then
			return anthemPants[teamid][side].id or val
		end
		return val
	end
	
	local function getAnthemPantsTextureVariation(teamid,side, val)
		if ((anthemPants[teamid] ~= nil) and (anthemPants[teamid][string.lower(side)] ~= nil)) then
			return anthemPants[teamid][side].var or val
		end
		return val
	end

local brts = ...
local ShaderParam = buildShaderExpressionParameterKeys(brts.shader_bindings)

local player = {}

--------------------------------------------------
local SETTING = {
	Generation = 5,
	UseFlexMaps = true,
	DecalsUseExtraMaps = true,
	EnableStrandHair = true,
	UseHandColliders = true,
	UseFullBody = true,
	UsePsdOfficial = true,
	UseAnisoSpecular = true,
	UseSpecularOcclusion = true,
	UsePackedAOMap = true,				-- RGB packed as {dry, wet, sweat). If false, loads individual ao maps.
	EnableHRCFacepaint = true,
	EnableHRCAvatarHead = true,
	EnableHRCProps = true,
	UsePSD = true,  -- doesn't load PSD assets but still can use GpuCompute
	UseBodyPSD = true, -- don't use body PSD when simplecloth, on Sprout
	UseBodyExertion = true,
	EnableShoeLacesCloth = true,
	LoadAllWarmupItems = true,
	UseCraniumHead = true,
	UseCraniumMaterialRecipe = true,
	GenerateRigidClothMask = true,
	UseHighresMouthbag = true,

	-- Lowres crowd settings
	EnableLRCCoeffMaps = false,			-- Load coeff maps (costs 5.5MB, but makes no discernable lighting difference to ultra jerseys. Recommend leaving it at false)
	EnableLRCJerseyCompositor = true,		-- Composite crests and brands on ultra jerseys
	EnableLRCFacepaint = true
}

-------------------------------------------------
-- HSL
-- x = hue (0.0 <-> 0.5 <--> 1.0), y = saturation (0.0 <-> 0.5 <--> 1.0), z = lightness (0.0 <-> 0.5 <--> 1.0) 
local PLAYER_SKINTONE_MALE_HSL_LIST = {
	{0.500, 0.500, 0.500},
    {0.495, 0.445, 0.500},     {0.500, 0.500, 0.500},
    {0.495, 0.500, 0.500},     {0.502, 0.500, 0.500},
    {0.501, 0.500, 0.500},     {0.499, 0.492, 0.500},
    {0.502, 0.487, 0.500},     {0.502, 0.500, 0.500},
    {0.501, 0.465, 0.500},     {0.502, 0.335, 0.500}
}

local PLAYER_LIPCOLOR_HSL_LIST = {
	{0.500, 0.500, 0.500},
	{0.504, 0.499, 0.500}, {0.513, 0.556, 0.500},
	{0.496, 0.480, 0.500}, {0.499, 0.525, 0.500},
	{0.500, 0.563, 0.500}, {0.482, 0.456, 0.500}
}

------------------------------------------------------------------------------------
-- Levels
-- x = inBlackPoint (0.0 <--> 1.0), y = inWhitePoint (0.0 <--> 1.0)
-- x = outBlackPoint (0.0 <--> 1.0), y = outWhitePoint (0.0 <--> 1.0)
-- z = substance midtone(0.001->1.0->16.0)
local PLAYER_SKINTONE_MALE_LEVEL_LIST = {
    {0.000, 1.000, 1.000, 0.000, 1.000},
    {0.000, 0.815, 1.000, 0.000, 0.788},     {0.000, 1.000, 1.000, 0.000, 0.880},
    {0.000, 0.702, 1.000, 0.000, 0.490},     {0.000, 0.664, 1.193, 0.000, 0.405},
    {0.000, 0.656, 1.234, 0.000, 0.335},     {0.000, 0.704, 1.350, 0.000, 0.287},
    {0.000, 0.688, 1.594, 0.000, 0.263},     {0.000, 0.654, 1.650, 0.000, 0.166},
    {0.000, 0.715, 1.739, 0.000, 0.110},     {0.000, 0.686, 2.606, 0.000, 0.088}
}
			
local PLAYER_LIPCOLOR_LEVEL_LIST = {
	{0.000, 1.000, 1.000, 0.000, 1.000},
	{0.023, 1.000, 0.799, 0.023, 1.000}, {0.040, 1.000, 0.930, 0.036, 0.663},
	{0.023, 1.000, 0.995, 0.040, 0.689}, {0.030, 0.949, 0.907, 0.033, 0.509},
	{0.047, 0.879, 0.990, 0.026, 0.314}, {0.014, 0.844, 1.263, 0.000, 0.112}
}

local EYE_COLOR_LIST = { 
	{1,1,1,1}, -- eye 0 is the mannequin
	{ 0.134 , 0.150 , 0.150, 1.000}, -- 1 - BLUE
	{ 0.309 , 0.303 , 0.295, 1.000}, -- 2 - LIGHTBLUE
	{ 0.129 , 0.064 , 0.044, 1.000}, -- 3 - BROWN
	{ 0.261 , 0.127 , 0.055, 1.000}, -- 4 - LIGHTBROWN
	{ 0.269 , 0.222 , 0.132, 1.000}, -- 5 - HAZEL
	{ 0.126 , 0.142 , 0.076, 1.000}, -- 6 - GREEN
	{ 0.263 , 0.182 , 0.096, 1.000}, -- 7 - LIGHTGREEN
	{ 0.212 , 0.209 , 0.203, 1.000}, -- 8 - MEDIUMBLUE
	{ 0.056 , 0.033 , 0.023, 1.000}, -- 9 - DARKBROWN
	{ 0.202 , 0.225 , 0.143, 1.000}, -- 10 - SATURATEDGREEN
	{ 0.693 , 0.119 , 0.031, 1.000}, -- 11 - AMBER
	{ 0.651 , 0.623 , 0.545, 1.000}, -- 12 - LIGHTGREY
	{ 0.456 , 0.439 , 0.386, 1.000}, -- 13 - MEDIUMGREY
	{ 0.496 , 0.171 , 0.783, 1.000}, -- 14 - VIOLET
	{ 0.783 , 0.533 , 0.048, 1.000} -- 15 - GOLDEN
}

local PLAYER_SKIN_LAYER_OPACITY_LIST = {
	0.00, 
	1.00, 1.00, 1.00, 1.00, 0.92, 
	0.90, 0.80, 0.75, 0.70, 0.65
}

local PLAYER_GUM_COLOR_LIST = {
	0, 0, 0, 1, 1, 1, 2, 2, 3, 3
}

-------------------------------------------------

local enum = {}

setEnum(enum, "ShaderDrawOrder")
setEnum(enum, "ShaderDrawOrderSubOrder")
setEnum(enum, "RenderFormat")

--TextureCompositeEnityData.ddf
setEnum(enum, "RuntimeGeneratedTexturesBlendMode")
setEnum(enum, "AlphaMode")
setEnum(enum, "RasterizedTextureFormat")

setEnum(enum, "OfficialType")
setEnum(enum, "WarmupTopType")
setEnum(enum, "WarmupBottomType")

setEnum(enum, "RenderBlendMode")
setEnum(enum, "RenderBlendOp")
setEnum(enum, "CryoBlendMode")
setEnum(enum, "CryoTextureMaskMode")
setEnum(enum, "CryoRecolorMode")
setEnum(enum, "CryoColorEncoding")
setEnum(enum, "CryoTextureColorChannel")

local slots = {
	head = "content/common/configs/slots/head_slot",
	mouthbag = "content/common/configs/slots/mouthbag_slot",
	cardhair = "content/common/configs/slots/card_hair_slot",
	haircap = "content/common/configs/slots/haircap_slot",
	hairacc = "content/common/configs/slots/hair_accessory_slot",
	eyelash = "content/common/configs/slots/eyelash_slot",

	beard = "content/common/configs/slots/beard_slot",
	beardcap = "content/common/configs/slots/beardcap_slot",

	strandhair = "strand_hair_slot",
	strandbeard = "strand_beard_slot",
	strandeyebrow = "strand_eye_brow_slot",

	shorts = "content/common/configs/slots/shorts_cloth_slot",
	gkpants = "content/common/configs/slots/gkpants_slot",
	shoes = "content/common/configs/slots/shoes_slot",
	jersey = "content/common/configs/slots/jersey_cloth_slot",
	socks = "content/common/configs/slots/socks_slot",

	top_base_recolor = "content/common/configs/slots/top_base_recolor_slot",
	top_second_recolor = "content/common/configs/slots/top_second_recolor_slot",
	bottom = "content/common/configs/slots/bottom_slot",
	bottom_second = "content/common/configs/slots/bottom_second_slot",
	wardrobe_socks = "content/common/configs/slots/wardrobe_sock_slot",

	underarms = "content/common/configs/slots/underarms_slot",
	underneck = "content/common/configs/slots/underneck_slot",
	undershorts = "content/common/configs/slots/undershorts_slot",

	gkglove = "content/common/configs/slots/gkglove_slot",

	arms = "content/common/configs/slots/arms_slot",
	arms_short = "content/common/configs/slots/arms_short_slot",
	legs = "content/common/configs/slots/legs_slot",
	bodyupper = "content/common/configs/slots/bodyupper_slot",
	bodylower = "content/common/configs/slots/bodylower_slot",

	warmup_bib = "content/common/configs/slots/warmup_bib_slot",
	warmup_pants = "content/common/configs/slots/warmup_pants_slot",
	warmup_jacket = "content/common/configs/slots/warmup_jacket_slot",

	shadow = "content/common/configs/slots/shadow_slot",

	crowdfan = "content/common/configs/slots/crowdfan_slot",

	sculptshapes = "content/common/configs/slots/sculptshapes_slot",
}

local crowdfan_prop_slots = {
	"content/common/configs/slots/crowdfan_prop1_slot",
	"content/common/configs/slots/crowdfan_prop2_slot",
	"content/common/configs/slots/crowdfan_prop3_slot",
	"content/common/configs/slots/crowdfan_prop4_slot",
	"content/common/configs/slots/crowdfan_prop5_slot",	
	"content/common/configs/slots/crowdfan_prop6_slot",	
}

local accessory_slots = {
	"content/common/configs/slots/accessory1_slot",
	"content/common/configs/slots/accessory2_slot",
	"content/common/configs/slots/accessory3_slot",
	"content/common/configs/slots/accessory4_slot",
}

local wardrobe_accessory_slots = {
	"content/common/configs/slots/wardrobe_accessory1_slot",
	"content/common/configs/slots/wardrobe_accessory2_slot",
	"content/common/configs/slots/wardrobe_accessory3_slot",
	"content/common/configs/slots/wardrobe_accessory4_slot",
}

local ref_accessories = {
	{ slot = "card_red_left",  model = 30, side = 0 },
	{ slot = "card_red_right", model = 30, side = 1 },
	{ slot = "card_yellow_left",  model = 28, side = 0 },
	{ slot = "card_yellow_right", model = 28, side = 1 },
	{ slot = "ref_book_left",  model = 34, side = 0 },
	{ slot = "ref_book_right", model = 34, side = 1 },
	{ slot = "ref_pen_left",  model = 32, side = 0 },
	{ slot = "ref_pen_right", model = 32, side = 1 },
	{ slot = "ref_watch_left", model = 4, side = 0 },
	{ slot = "ref_earpiece_left", model = 2, side = 0 },
	{ slot = "ref_gltwatch_right", model = 20, side = 1 },
}

-- many geo's include lods as ports of fbx, no need to specify lods
local lod0 = 0
-- most meshes don't contribute to bounding box computations as it will be very expensive
-- but at least few have to, otherwise the model will be invisible
-- we have lod2 and shadow mesh contributing to bbox
local noBoundingBox = false
local updateBoundingBox = true

local playerDrawOrder = enum.ShaderDrawOrder_Pitch
local playerDrawOrder_Default = enum.ShaderDrawOrder_Default

local playerDrawSubOrder = enum.ShaderDrawOrderSubOrder_Player_Clothes
local playerDrawSubOrder_Clothes = enum.ShaderDrawOrderSubOrder_Player_Clothes
local playerDrawSubOrder_Body = enum.ShaderDrawOrderSubOrder_Player_Body
local playerDrawSubOrder_Hair = enum.ShaderDrawOrderSubOrder_Player_Hair
local playerDrawSubOrder_Haircap = enum.ShaderDrawOrderSubOrder_Player_Haircap
local playerDrawSubOrder_Accessory = enum.ShaderDrawOrderSubOrder_Player_Accessory

local jersey_wet_ao_channel_select = {
	dry 	= {1, 0, 0, 0},
	wet 	= {0, 1, 0, 0},
	sweat 	= {0, 0, 1, 0},
}

-- for generic kit templates
local GENERIC_KIT_TEMPLATE_ID = 7900

-- PSD head/jersey masking
-- fancy artworks names
local PSD_HEAD_MASKING = {
	"Low",     -- round
	"MidHigh", -- mock turtle
	"MidHigh", -- turt leneck
	"MidLow",  -- new adidas
	"MidLow",  -- new nike
	"MidLow",  -- new puma
	"MidLow",  -- sidevneck
	"MidLow",  -- vneck
	"MidHigh", -- fold medium
	"MidHigh", -- fold medium round
	"MidHigh", -- fold small
	"MidHigh", -- polo
	"Low",     -- puma chipped sides
	"MidLow",  -- addidas chipped center 1
	"MidLow",  -- addidas chipped center 2
	"MidHigh", -- banded polo
	"MidLow",  -- addidas chipped center 3
	"MidLow",  -- fold small vneck
	"MidHigh", -- minipolo
	"Low",     -- square neck
	"Low",     -- roundcenter chip
	"Low",     -- vneck chipped center
	"MidLow",  -- adidas high vneck
	"MidLow",  -- nike back chip
	"MidLow"   -- nike doublev	
}

-- Head sculpt control shapes
-------------------------------------------------
local SculptShapeNames_Fat = {
	"ctrl_fa_cheeksMiddle_NL_XXX", "ctrl_fa_cheeksMiddle_NR_XXX", "ctrl_fa_cheeks_NL_XMX", "ctrl_fa_cheeks_NR_XMX", "ctrl_fa_earHelix_NL_IXX", "ctrl_fa_earHelix_NL_SXX", "ctrl_fa_earHelix_NR_IXX", "ctrl_fa_earHelix_NR_SXX",
	"ctrl_fa_forehead_NL_XLX", "ctrl_fa_forehead_NN_XMX", "ctrl_fa_forehead_NR_XLX", "ctrl_fa_jowl_NL_IXX", "ctrl_fa_jowl_NL_SXX", "ctrl_fa_jowl_NR_IXX", "ctrl_fa_jowl_NR_SXX", "ctrl_fa_lip_NL_IXX", "ctrl_fa_lip_NL_SXX",
	"ctrl_fa_lip_NR_IXX", "ctrl_fa_lip_NR_SXX", "ctrl_fa_mental_NN_IXX", "ctrl_fa_mental_NN_XXX", "ctrl_fa_nasolabial_NL_IXX", "ctrl_fa_nasolabial_NL_SXX", "ctrl_fa_nasolabial_NR_IXX", "ctrl_fa_nasolabial_NR_SXX",
	"ctrl_fa_neck_NL_XXP", "ctrl_fa_neck_NR_XXP", "ctrl_fa_nose_NN_XXX", "ctrl_fa_orbital_NL_IXX", "ctrl_fa_orbital_NL_SXX", "ctrl_fa_orbital_NL_XLX", "ctrl_fa_orbital_NR_IXX", "ctrl_fa_orbital_NR_SXX", "ctrl_fa_orbital_NR_XLX",
	"ctrl_fa_periorbital_NL_IXX", "ctrl_fa_periorbital_NR_IXX", "ctrl_fa_preplatysmal_NL_XXX", "ctrl_fa_preplatysmal_NR_XXX", "ctrl_fa_submandibular_NL_XXX", "ctrl_fa_submandibular_NR_XXX", "ctrl_fa_submental_NL_XXX",
	"ctrl_fa_submental_NR_XXX", "ctrl_fa_temporal_NL_XLX", "ctrl_fa_temporal_NR_XLX"
}

local SculptShapeNames_Flesh = {
	"ctrl_ca_earAntihelix_NL_IXX", "ctrl_ca_earAntihelix_NL_SXX", "ctrl_ca_earAntihelix_NR_IXX", "ctrl_ca_earAntihelix_NR_SXX", "ctrl_ca_earHelix_NL_IXX", "ctrl_ca_earHelix_NL_SXA", "ctrl_ca_earHelix_NL_SXP",
	"ctrl_ca_earHelix_NL_XXX", "ctrl_ca_earHelix_NR_IXX", "ctrl_ca_earHelix_NR_SXA", "ctrl_ca_earHelix_NR_SXP", "ctrl_ca_earHelix_NR_XXX", "ctrl_ca_earlobe_NL_XXX", "ctrl_ca_earlobe_NR_XXX", "ctrl_ca_eartragus_NL_XXX",
	"ctrl_ca_eartragus_NR_XXX", "ctrl_ca_noseAla_NL_ICX", "ctrl_ca_noseAla_NL_ILX", "ctrl_ca_noseAla_NL_IMX", "ctrl_ca_noseAla_NL_IXX", "ctrl_ca_noseAla_NL_SXX", "ctrl_ca_noseAla_NL_XXA", "ctrl_ca_noseAla_NR_ICX",
	"ctrl_ca_noseAla_NR_ILX", "ctrl_ca_noseAla_NR_IMX", "ctrl_ca_noseAla_NR_IXX", "ctrl_ca_noseAla_NR_SXX", "ctrl_ca_noseAla_NR_XXA", "ctrl_ca_noseColumella_NN_XXX", "ctrl_ca_noseSupratip_NN_XXX", "ctrl_ca_noseTip_NN_XXX",
	"ctrl_fl_buccalRecess_NL_XXX", "ctrl_fl_buccalRecess_NR_XXX", "ctrl_fl_buccomandibularGroove_NL_XXX", "ctrl_fl_buccomandibularGroove_NR_XXX", "ctrl_fl_chinCleft_NN_XXX", "ctrl_fl_epicanthic_NL_XCX", "ctrl_fl_epicanthic_NL_XLX",
	"ctrl_fl_epicanthic_NL_XMX", "ctrl_fl_epicanthic_NR_XCX", "ctrl_fl_epicanthic_NR_XLX", "ctrl_fl_epicanthic_NR_XMX", "ctrl_fl_eyelids_NL_ICX", "ctrl_fl_eyelids_NL_ILX", "ctrl_fl_eyelids_NL_IMX", "ctrl_fl_eyelids_NL_SCX",
	"ctrl_fl_eyelids_NL_SLX", "ctrl_fl_eyelids_NL_SMX", "ctrl_fl_eyelids_NL_XLX", "ctrl_fl_eyelids_NL_XMX", "ctrl_fl_eyelids_NR_ICX", "ctrl_fl_eyelids_NR_ILX", "ctrl_fl_eyelids_NR_IMX", "ctrl_fl_eyelids_NR_SCX",
	"ctrl_fl_eyelids_NR_SLX", "ctrl_fl_eyelids_NR_SMX", "ctrl_fl_eyelids_NR_XLX", "ctrl_fl_eyelids_NR_XMX", "ctrl_fl_lipLower_NL_ICX", "ctrl_fl_lipLower_NL_ILX", "ctrl_fl_lipLower_NL_IXX", "ctrl_fl_lipLower_NL_SLX",
	"ctrl_fl_lipLower_NN_IMX", "ctrl_fl_lipLower_NN_SMX", "ctrl_fl_lipLower_NR_ICX", "ctrl_fl_lipLower_NR_ILX", "ctrl_fl_lipLower_NR_IXX", "ctrl_fl_lipLower_NR_SLX", "ctrl_fl_lipUpper_NL_ILX", "ctrl_fl_lipUpper_NL_SCX",
	"ctrl_fl_lipUpper_NL_SLX", "ctrl_fl_lipUpper_NL_SXX", "ctrl_fl_lipUpper_NN_IMX", "ctrl_fl_lipUpper_NN_SMX", "ctrl_fl_lipUpper_NR_ILX", "ctrl_fl_lipUpper_NR_SCX", "ctrl_fl_lipUpper_NR_SLX", "ctrl_fl_lipUpper_NR_SXX",
	"ctrl_fl_lip_NL_XCX", "ctrl_fl_lip_NL_XLX", "ctrl_fl_lip_NN_XMX", "ctrl_fl_lip_NR_XCX", "ctrl_fl_lip_NR_XLX", "ctrl_fl_mandibularGroove_NL_XXX", "ctrl_fl_mandibularGroove_NR_XXX", "ctrl_fl_nasojugalGroove_NL_XXX",
	"ctrl_fl_nasojugalGroove_NR_XXX", "ctrl_fl_nasolabialGroove_NL_IXX", "ctrl_fl_nasolabialGroove_NL_SXX", "ctrl_fl_nasolabialGroove_NR_IXX", "ctrl_fl_nasolabialGroove_NR_SXX", "ctrl_fl_orbitalGroove_NL_IXX",
	"ctrl_fl_orbitalGroove_NR_IXX", "ctrl_fl_oromentalGroove_NL_XXX", "ctrl_fl_oromentalGroove_NR_XXX", "ctrl_fl_philtrum_NN_XXX", "ctrl_mu_corrugator_NL_XXX", "ctrl_mu_corrugator_NR_XXX", "ctrl_mu_masseter_NL_XXX",
	"ctrl_mu_masseter_NR_XXX", "ctrl_mu_platysma_NL_ILX", "ctrl_mu_platysma_NL_SLX", "ctrl_mu_platysma_NN_IMX", "ctrl_mu_platysma_NN_SMX", "ctrl_mu_platysma_NR_ILX", "ctrl_mu_platysma_NR_SLX", "ctrl_mu_procerus_NN_XXX",
	"ctrl_mu_sternomastoid_NL_XXX", "ctrl_mu_sternomastoid_NR_XXX", "ctrl_mu_temporalis_NL_XXX", "ctrl_mu_temporalis_NR_XXX", "ctrl_mu_trapezius_NN_SXX"
}

local SculptShapeNames_Skeletal = {
	"ctrl_bs_brow_NL_SMX", "ctrl_bs_brow_NL_XLX", "ctrl_bs_brow_NN_XMX", "ctrl_bs_brow_NR_SMX", "ctrl_bs_brow_NR_XLX", "ctrl_bs_canine_NL_IXX", "ctrl_bs_canine_NL_XXX", "ctrl_bs_canine_NR_IXX",
	"ctrl_bs_canine_NR_XXX", "ctrl_bs_chin_NN_SXX", "ctrl_bs_chin_NN_XXX", "ctrl_bs_coronal_NN_SXX", "ctrl_bs_cuspid_NL_SXX", "ctrl_bs_cuspid_NL_XXX", "ctrl_bs_cuspid_NR_SXX", "ctrl_bs_cuspid_NR_XXX",
	"ctrl_bs_forehead_NN_XXX", "ctrl_bs_incisorLower_NL_SLX", "ctrl_bs_incisorLower_NL_SMX", "ctrl_bs_incisorLower_NL_XLX", "ctrl_bs_incisorLower_NL_XMX", "ctrl_bs_incisorLower_NR_SLX", "ctrl_bs_incisorLower_NR_SMX",
	"ctrl_bs_incisorLower_NR_XLX", "ctrl_bs_incisorLower_NR_XMX", "ctrl_bs_incisor_NL_ILX", "ctrl_bs_incisor_NL_IMX", "ctrl_bs_incisor_NL_XLX", "ctrl_bs_incisor_NL_XMX", "ctrl_bs_incisor_NR_ILX", "ctrl_bs_incisor_NR_IMX",
	"ctrl_bs_incisor_NR_XLX", "ctrl_bs_incisor_NR_XMX", "ctrl_bs_mandible_NL_IXA", "ctrl_bs_mandible_NL_SXA", "ctrl_bs_mandible_NL_XXP", "ctrl_bs_mandible_NR_IXA", "ctrl_bs_mandible_NR_SXA", "ctrl_bs_mandible_NR_XXP",
	"ctrl_bs_maxilla_NL_IXX", "ctrl_bs_maxilla_NL_SXX", "ctrl_bs_maxilla_NR_IXX", "ctrl_bs_maxilla_NR_SXX", "ctrl_bs_molarsLower_NL_XXX", "ctrl_bs_molarsLower_NR_XXX", "ctrl_bs_molars_NL_XXX", "ctrl_bs_molars_NR_XXX",
	"ctrl_bs_noseBridge_NN_XXX", "ctrl_bs_noseRoot_NN_XXX", "ctrl_bs_nose_NN_XXX", "ctrl_bs_orbits_NL_SXX", "ctrl_bs_orbits_NL_XXX", "ctrl_bs_orbits_NR_SXX", "ctrl_bs_orbits_NR_XXX", "ctrl_bs_skull_NN_SXX",
	"ctrl_bs_skull_NN_XXP", "ctrl_bs_teethLower_NN_XXA", "ctrl_bs_teeth_NN_XXA", "ctrl_bs_teeth_NN_XXX", "ctrl_bs_temple_NL_XXX", "ctrl_bs_temple_NR_XXX", "ctrl_bs_zygomaxilla_NL_XXX", "ctrl_bs_zygomaxilla_NR_XXX",
	"ctrl_ca_adamsapple_NN_XXX", "ctrl_ca_ears_NL_XXX", "ctrl_ca_ears_NR_XXX", "ctrl_ca_laryngeal_NN_XXX", "ctrl_fl_eyes_NL_XXX", "ctrl_fl_eyes_NR_XXX"
}

local SculptShapeNames_Secondary = {
	"ctrl_sf_browRidge_NN_XXX", "ctrl_sf_chin_NN_XXX", "ctrl_sf_clavicles_NN_XXX", "ctrl_sf_ears_NN_XXX", "ctrl_sf_eyebags_NN_XXX", "ctrl_sf_eyelids_NN_XXX", "ctrl_sf_frontalEminences_NN_XXX", 
	"ctrl_sf_infraorbitalFurrows_NN_XXX", "ctrl_sf_jaw_NN_XXX", "ctrl_sf_jowls_NN_XXX", "ctrl_sf_labiomentalFat_NN_XXX", "ctrl_sf_larynx_NN_XXX", "ctrl_sf_lowerLip_NN_XXX", "ctrl_sf_lowerVermilion_NN_XXX", 
	"ctrl_sf_mouthCorners_NN_XXX", "ctrl_sf_nasolabialFat_NN_XXX", "ctrl_sf_noseBridge_NN_XXX", "ctrl_sf_noseTip_NN_XXX", "ctrl_sf_nostrils_NN_XXX", "ctrl_sf_palpebralLigaments_NN_XXX", "ctrl_sf_philtrum_NN_XXX", 
	"ctrl_sf_sternocleidomastoids_NN_XXX", "ctrl_sf_superiorOrbitalFat_NN_XXX", "ctrl_sf_temporalis_NN_XXX", "ctrl_sf_temporalLines_NN_XXX", "ctrl_sf_upperLip_NN_XXX", "ctrl_sf_upperVermilion_NN_XXX", 
	"ctrl_sf_zygomaticBones_NN_XXX"
}

local SecondaryFormsNames = {
	"brow_ridge","chin","clavicles","ears","eyebags","eyelids","frontal_eminences","infraorbital_furrows","jaw","jowls",
	"labiomental_fat","larynx","lower_lip","lower_vermilion","mouth_corners","nasolabial_fat","nose_bridge","nose_tip",
	"nostrils","palpebral_ligaments","philtrum","sternocleidomastoids",	"superior_orbital_fat","temporalis","temporal_lines",
	"upper_lip","upper_vermilion","zygomatic_bones"
}

-------------------------------------------------
local gloveid = 16 -- glove id 
local sleevesid = 52 -- sleeves id

-------------------------------------------------
local Env = getEnvironment()
local Platform = Env.Platform
local PlatformMode = Env.PlatformMode
local MemTotal = Env.MemTotal / (1024*1024)
local MemAvailable = Env.MemAvailable / (1024*1024)
local strandEnabled = Env.StrandBasedHairEnabled

-- 2GB on iphone 12
local LOW_MEM_LIMIT = 3 * 1024

-- this might need better specialization
-- yury todo: set configuration for Sprout
--local IS_MOBILE = (Platform == "Nx" or Platform ==  "Sprout" or Platform == "Android" or Platform == "iOS")
local IS_MOBILE = (Platform == "Nx" or Platform == "Android" or Platform == "iOS")
local IS_ASTC = (Platform == "Android" or Platform == "iOS")
local IS_DXT = not IS_ASTC

math.randomseed(19992021)

--log(string.format("[lua] platform=%s mode = %s strandEnabled = %s is_mobile = %s", Platform, PlatformMode, strandEnabled, IS_MOBILE))
log(("[lua] platform = %s mode = %s strandEnabled = %s is_astc = %s"):format(Platform, PlatformMode, strandEnabled, IS_ASTC))
log(("[lua] memTotal = %.1f Mb memAvailable = %.1f Mb"):format(MemTotal, MemAvailable))

-------------------------------------------------
-- texture compositing descriptions
local BadgeColorCompositorDesc = {
	width = 2048, height = 2048, format = enum.RenderFormat_BC3_SRGB,
	baselayer_alphamode = enum.AlphaMode_Additive,
}

local BadgeNormalCompositorDesc = {
	width = 1024, height = 1024, format = enum.RenderFormat_BC5_UNORM,
	baselayer_alphamode = enum.AlphaMode_None,
}

local BadgeCoeffCompositorDesc = {
	width = 1024, height = 1024, format = enum.RenderFormat_BC1_UNORM,
	baselayer_alphamode = enum.AlphaMode_None,
}

local CullMaskCompositorDesc = {
	width = 128, height = 128, format = enum.RenderFormat_BC4_UNORM,
	baselayer_alphamode = enum.AlphaMode_None,
}

local BodyCompositorDesc = {
	width = 1024, height = 1024, format = enum.RenderFormat_BC1_SRGB,
	baselayer_alphamode = enum.AlphaMode_None,
}

local FaceCompositorDesc = {
	width = 1024, height = 1024, format = enum.RenderFormat_BC1_SRGB,
}

local FaceNormalCompositorDesc = {
	width = 1024, height = 1024, format = enum.RenderFormat_BC5_UNORM,
}

local FaceSpecMaskCompositorDesc = {
	width = 1024, height = 1024, format = enum.RenderFormat_BC4_UNORM,
}

local ClothMaskCompositorDesc = {
	width = 512, height = 512, format = enum.RenderFormat_BC4_UNORM,
}
local LowResCrowdJerseyCompositorDesc = { width = 1024, height = 1024, format = enum.RenderFormat_BC1_SRGB }

-- override compositor resolutions per platform
if IS_MOBILE then
	local div = MemAvailable > LOW_MEM_LIMIT and 2 or 4
	log(("[lua] texture compositor size downscaler %d"):format(div))

	local _adjustSizes = function(desc)
		desc.width = desc.width // div
		desc.height = desc.height // div
	end
	
	-- aligned with Texture Groups
	_adjustSizes(BadgeColorCompositorDesc)
	_adjustSizes(BadgeNormalCompositorDesc)
	_adjustSizes(BadgeCoeffCompositorDesc)

	_adjustSizes(BodyCompositorDesc)

	-- only one level down for faces
	-- don't change it, as it is aligned with Texture Groups and only applies to cranium, you will not get savings with star players team
	FaceCompositorDesc.width, FaceCompositorDesc.height = 512, 512
	FaceNormalCompositorDesc.width, FaceNormalCompositorDesc.height = 512, 512
	FaceSpecMaskCompositorDesc.width, FaceSpecMaskCompositorDesc.height = 512, 512

	_adjustSizes(LowResCrowdJerseyCompositorDesc)
	
	-- disable PSD assets, the module is disabled in Game.cfg
	SETTING.UsePSD = false
end

if Platform == "Sprout" then
	SETTING.EnableShoeLacesCloth = false
	SETTING.EnableStrandHair = false
	SETTING.UseBodyPSD = false
end

-------------------------------------------------
-- helper functions

local function _unpackUByte4N(src)
	local x = ((src >>  0) & 0xFF) / 255.0
	local y = ((src >>  8) & 0xFF) / 255.0
	local z = ((src >> 16) & 0xFF) / 255.0
	local w = ((src >> 24) & 0xFF) / 255.0
	return {x, y, z, w}
end

local function _packUByte4N(vec)
	local ix = math.floor(vec[1] * 255.0 + 0.5) | 0 -- convert to integer
	local iy = math.floor(vec[2] * 255.0 + 0.5) | 0
	local iz = math.floor(vec[3] * 255.0 + 0.5) | 0
	local iw = math.floor(vec[4] * 255.0 + 0.5) | 0
	return (ix & 0xFF) | ((iy & 0xFF) << 8) | ((iz & 0xFF) << 16) | ((iw & 0xFF) << 24)
	--return {ix, iy, iz, iw}
end

local function _sRGBToLinear(sRGB4)
	-- local C = sRGB4
	--return { C[1] ^ 2.2, C[2] ^ 2.2, C[3] ^ 2.2, C[4] }
	-- accurate
	local lo = {}
	local hi = {}
	local islow = true
	for i, v in ipairs(sRGB4) do
		lo[i] = v / 12.92
		hi[i] = ((v + 0.055)/1.055) ^ 2.4
		islow = islow and v < 0.04045
	end
	return islow and lo or hi
end

local function _remapToPBR(sRGB4)
	-- lo = 0.118 (30),  hi = 0.941 (240)
	-- ratio = hi - lo  ()
	-- remmaped = c * ratio + lo
	local C = sRGB4
	return { C[1] * 0.823 + 0.118, 
		     C[2] * 0.823 + 0.118,
		     C[3] * 0.823 + 0.118 }
end

local function _luminance(sRGB4)
	local C = sRGB4
	return  (C[1]*0.3) + (C[2]*0.59) + (C[3]*0.11)
end

local function _color4To3(color4)
	return {color4[1], color4[2], color4[3]}
end


--[[
	EAStdC RandomUint32WeightedChoice
	Return value is from 0 to nLimit-1 inclusively, with probabilities proportional to weights.
	The input array weights must be of length <nLimit>. These values are used to 
	determine the probability of each choice. That is, weight[i] is proportional 
	to the probability that this function will return i. Negative values are ignored. 
	This function is useful in generating a custom distribution.
	Ex: 
		index = _randomWeightedChoice({128, 64, 32, 16, 8, 4, 2})
]]--
local function _randomWeightedChoice(weights)
	local limit = #weights
	if limit == 1 then return limit end

	local weightedSum = 0
	for i = 1, limit do
		weightedSum = weightedSum + (weights[i] > 0 and weights[i] or 0) 
	end

	if weightedSum <= 0 then return math.random(limit) end

	local value = math.random(weightedSum)

	for i = 1, limit do
		local w = weights[i]
		if w > 0 then
			if value < w then return i end
			value = value - w
		end
	end
	return limit
end

local function _isChild(initData)
	local is_child = initData.Age < 14
	return is_child
end

local function _getCryoBlendmode(blendmode)
	local cryoBlendMode = enum.CryoBlendMode_Disabled

	if blendmode == enum.BlendMode_AlphaBlend then
		cryoBlendMode = enum.CryoBlendMode_LinearAlphaBlend
	elseif blendmode == enum.BlendMode_Multiply then
		cryoBlendMode = enum.CryoBlendMode_Multiply
	elseif blendmode == enum.BlendMode_HardLight then
		cryoBlendMode = enum.CryoBlendMode_HardLight
	end
	return cryoBlendMode
end


-------------------------------------------------------------------------------------
local function _getEyebrowColors(initData, args)
	local isGeneric = initData.HeadClass ~= 0 or args.force_generic
	local c1, c2, c3 = {1,0,0,0}, {0,1,0,0}, {0,0,1,0}
	if isGeneric then 
		c1 = _sRGBToLinear(initData.EyebrowColorPri)
		c2 = _sRGBToLinear(initData.EyebrowColorSec)
		c3 = _sRGBToLinear(initData.EyebrowColorTer)
	end

	return  c1,c2,c3
end

-------------------------------------------------------------------------------------
local function _getFacialHairColors(initData, args)
	local isGeneric = initData.HeadClass ~= 0 or args.force_generic
	local c1, c2, c3 = {1,0,0,0}, {0,1,0,0}, {0,0,1,0}
	if isGeneric then 
		c1 = _sRGBToLinear(initData.FacialHairColorPri)
		c2 = _sRGBToLinear(initData.FacialHairColorSec)
		c3 = _sRGBToLinear(initData.FacialHairColorTer)
	end

	return  c1,c2,c3
end

-------------------------------------------------------------------------------------
local function _getHairColors(initData, args)
	local isGeneric = initData.HeadClass ~= 0 or args.force_generic
	local c1, c2, c3 = {1,0,0,0}, {0,1,0,0}, {0,0,1,0}
	if isGeneric then 
		c1 = _sRGBToLinear(initData.HairColorPri)
		c2 = _sRGBToLinear(initData.HairColorSec)
		c3 = _sRGBToLinear(initData.HairColorTer)
	end

	return  c1,c2,c3
end

-------------------------------------------------
local function _addDirtShaderParams(material, initData, dirtMap, dirtMask)

	material:addTexture(ShaderParam.dirtMapArrayTexture, dirtMap)

	material:addTexture(ShaderParam.dirtMaskTexture, dirtMask)


	material:addVector(ShaderParam.dirtLightColor, initData.DirtColorPri)

	material:addVector(ShaderParam.dirtDarkColor, initData.DirtColorSec)

	material:addVector(ShaderParam.dirtMaxColor, initData.DirtColorTer)
end

local function _addEffectShaderParams(material, effectParams, decalEffectParams)
	if effectParams then

		material:addVector(ShaderParam.effectParams, effectParams.Bounds)
	end
	if decalEffectParams then
		material:addVector(ShaderParam.decalEffectParams, decalEffectParams.Bounds)
	end
end

local function _addWeaveShaderParams(material, weaveCoeffMapArray, weaveNormalMapArray, tile_amounts)

	material:addTexture(ShaderParam.weaveNormalArrayTexture, weaveNormalMapArray)

	material:addTexture(ShaderParam.weaveCoeffArrayTexture, weaveCoeffMapArray)	

	if tile_amounts then

		material:addVector(ShaderParam.weaveTiles, tile_amounts)
	end
end

local function _readGenericHotspotData(hotspot_file, group, name, default_bounds)
	local default_hotspot = default_bounds or {-1,-1,-1,-1}
	local default_rotation = 0.0
	local bounds, rotation = default_hotspot, default_rotation
	if hotspot_file then
		local hotspot_entry = getHotspotEntry(hotspot_file, group, name)
		if hotspot_entry then
			bounds = hotspot_entry.Bounds or default_hotspot
			rotation = hotspot_entry.Rotation or default_rotation
		end
	end
	return {Bounds = bounds, Rotation = rotation}
end

local function _readTattooBlendModeData(hotspot_file, group, name, default)
	local default_blendmodes = default or {0,0,0,0}
	if hotspot_file then
		local hotspot_entry = getHotspotEntry(hotspot_file, group, name)
		if hotspot_entry then
			bounds = hotspot_entry.Bounds or default_blendmodes
			--rotation = hotspot_entry.Rotation or default_rotation
		end
	end
	return {Bounds = bounds}
end

-- hair material helpers
local function _addHairShaderParams(material, initData, args)
	local c1,c2,c3 = _getHairColors(initData,args)

	material:addVector(ShaderParam.primaryColor, _color4To3(c1))

	material:addVector(ShaderParam.secondaryColor, _color4To3(c2))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(c3))
end

local function _addHairMaterials(item, initData, args)
	_addHairShaderParams(item:addMaterial("hair_mat"), initData, args)
	_addHairShaderParams(item:addMaterial("haircap_mat"), initData, args)
	_addHairShaderParams(item:addMaterial("hairlod_mat"), initData, args)
end


local function _addFacialHairShaderParams(material, initData, args)
	local c1,c2,c3 = _getFacialHairColors(initData,args)

	material:addVector(ShaderParam.primaryColor, _color4To3(c1))

	material:addVector(ShaderParam.secondaryColor, _color4To3(c2))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(c3))
end

local function _addFacialHairMaterials(item, initData, args)
	_addFacialHairShaderParams(item:addMaterial("hair_mat"), initData, args)
	_addFacialHairShaderParams(item:addMaterial("haircap_mat"), initData, args)
	_addFacialHairShaderParams(item:addMaterial("hairlod_mat"), initData, args)
end

local function _addMuscleFlexParams(material, flexMask, flexNormalMap, flexAmbientMap)
	if(SETTING.UseFlexMaps) then

		material:addTexture(ShaderParam.flexMaskTexture, flexMask)

		material:addTexture(ShaderParam.flexNormalTexture, flexNormalMap)

		material:addTexture(ShaderParam.flexOverlayTexture, flexAmbientMap)
	end
end

local function _addBrandWithHotspot(material, colorMap, coeffMap, normalMap, bounds)

	material:addTexture(ShaderParam.brandColorTexture, colorMap)

	material:addTexture(ShaderParam.brandCoeffTexture, coeffMap)

	if(SETTING.DecalsUseExtraMaps) then

		material:addTexture(ShaderParam.brandNormalTexture, normalMap)
	end
	
	material:addVector(ShaderParam.brandBounds, bounds)
end

local function _addCrestWithHotspot(material, colorMap, coeffMap, normalMap, bounds)

	material:addTexture(ShaderParam.crestTexture, colorMap)

	material:addTexture(ShaderParam.crestCoeffTexture, coeffMap)

	if(SETTING.DecalsUseExtraMaps) then

		material:addTexture(ShaderParam.crestNormalTexture, normalMap)
	end
	
	material:addVector(ShaderParam.crestBounds, bounds)
end

local function _usePsd(initData)
	if SETTING.UsePSD == false then 
		return false 
	end

	local official = initData.OfficialType

	-- don't load PSD data for referees on gen3 to save memory
	local isOfficial = (official == enum.OfficialType_Referee or 
		official == enum.OfficialType_Linesman or 
		official == enum.OfficialType_Fourth or
		official == enum.OfficialType_Manager)
	if not SETTING.UsePsdOfficial and isOfficial then 
		return false 
	end

	return true
end

-- this function has to be called before addMeshLodPair
local function _addPsdTags(initData, args, item, ...)
	item:ignoreMeshDeformer(args.use_gpucompute == false)
	item:setTagHashes(...)
end

-- bind functions
-----------------------------------------------------------------------------
local function bindShorts(initData, args, shorts_mesh, 
						  colorMap,coeffMap, aoMap, normalMap, bentNormalMap,
						  wrinkleMap, twistMap, dirtMap, dirtMask, 
						  numberTensMap, numberUnitsMap, hotspotAsset, 
						  crestColorMap, crestNormalMap, crestCoeffMap, 
						  brandColorMap, brandNormalMap, brandCoeffMap, 
						  taaMap, weaveNormalMapArray, weaveCoeffMapArray)
						  
	local bbox_update = args.static_shorts and updateBoundingBox or noBoundingBox
	local is_goalie = initData.ShortStyle == 1 
	local slot = is_goalie and slots.gkpants or slots.shorts
	local cull_tag_name = is_goalie and "GkPants" or "ShortsCloth"
	local is_mascot = initData.OfficialType == enum.OfficialType_Mascot

	-- many geo's include lods as ports of fbx, no need to specify lods
	local item = createItem("shorts", slot, initData.laneId)
	item:setIncludeCullTagHashes(cull_tag_name)

	item:enableWarpCloth(args.use_warpcloth)
	
	item:addMeshLodPair(lod0, shorts_mesh, bbox_update, playerDrawOrder, playerDrawSubOrder)

	-- vectors
	local no_effect = {Bounds = {0,0,0,0} }
	local zero_padding = is_mascot
	local hotspot = getHotspotTensAndUnits(hotspotAsset, initData.ShortsNumberVisible, initData.KitNumber, "shorts", "number", zero_padding)
	local crest_bounds = getHotspotEntry(hotspotAsset, "shorts", "team")
	local brand_bounds = getHotspotEntry(hotspotAsset, "shorts", "brand")
	local weave_tiles = getHotspotEntry(hotspotAsset, "shorts", "weave_tiles")
	local effectParams = getHotspotEntry(hotspotAsset, "shorts", "effectParams") or no_effect
	local decalEffectParams = getHotspotEntry(hotspotAsset, "shorts", "decalEffectParams") or no_effect

	if is_goalie then
		local no_hotspot = {-1, -1, -1, -1}
		hotspot.Units = no_hotspot
		hotspot.Tens = no_hotspot
		crest_bounds.Bounds = no_hotspot
	end

	-- material
	local material = item:addMaterial("shorts_mat")

	-- textures

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.ambientTexture, aoMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.normalArrayTexture, wrinkleMap)

	material:addTexture(ShaderParam.twistMaskTexture, twistMap)

	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end
	

	material:addTexture(ShaderParam.numberTensTexture, numberTensMap)

	material:addTexture(ShaderParam.numberUnitsTexture, numberUnitsMap)


	material:addTexture(ShaderParam.taaTexture, taaMap)

	_addCrestWithHotspot(material, crestColorMap, crestCoeffMap, crestNormalMap, crest_bounds.Bounds)
	_addBrandWithHotspot(material, brandColorMap, brandCoeffMap, brandNormalMap, brand_bounds.Bounds)

	_addWeaveShaderParams(material, weaveCoeffMapArray, weaveNormalMapArray, weave_tiles.Bounds)
	_addDirtShaderParams(material, initData, dirtMap, dirtMask)

	_addEffectShaderParams(material, effectParams, decalEffectParams)


	material:addVector(ShaderParam.numberUnitsBounds, hotspot.Units)

	material:addVector(ShaderParam.numberTensBounds, hotspot.Tens)


	material:addVector(ShaderParam.primaryColor, _color4To3(initData.KitColorShortPri))

	material:addVector(ShaderParam.secondaryColor, _color4To3(initData.KitColorShortSec))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.KitColorShortTer))


	material:addVector(ShaderParam.primaryNumberColor, initData.ShortsNumberColorPri)

	material:addVector(ShaderParam.secondaryNumberColor, initData.ShortsNumberColorSec)

	material:addVector(ShaderParam.tertiaryNumberColor, initData.ShortsNumberColorTer)

	-- default dry ao map. player_bp schematics can override this param based on weather setup

	-- ES conversion: this wasn't found in any SG shader, is it still in use?
	-- material:addVector(ShaderParam.ambientWetChannelSelect, jersey_wet_ao_channel_select.dry) 

	return item
end

-----------------------------------------------------------------------------
local function bindJersey(initData, args, jersey_item, jersey_mesh, 
						  colorMap, coeffMap, aoMap, normalMap, bentNormalMap,
						  wrinkleMap, twistMap, dirtMap, dirtMask, 
						  numberTensMap, numberUnitsMap, numberTensFrontMap, numberUnitsFrontMap, hotspotAsset, 
						  badgeMap, normalGeneratedMap, coeffGeneratedMap, playerNameGeneratedMap,
						  crestColorMap, crestNormalMap, crestCoeffMap, 
						  brandColorMap, brandNormalMap, brandCoeffMap, 
						  taaMap, weaveNormalMapArray, weaveCoeffMapArray)

	local bbox_update = args.static_jersey and updateBoundingBox or noBoundingBox
	local is_mascot = initData.OfficialType == enum.OfficialType_Mascot

	-- Create item if not provided
	local item = jersey_item
	if not item then
		item = createItem("jersey", slots.jersey, initData.laneId)
		item:enableWarpCloth(args.use_warpcloth)
		item:addMeshLodPair(lod0, jersey_mesh, bbox_update, playerDrawOrder, playerDrawSubOrder)
	end

	item:setTagHashes("jersey")
	item:setIncludeCullTagHashes("JerseyCloth", "JerseyNoCloth")
	--item:setExcludeCullTagHashes("WarmupGear")

	-- hotspots
	local no_hotspot = { Bounds = {-1, -1, -1, -1}, Rotation=0 }
	local no_effect = {Bounds = {0,0,0,0} }
	local zero_padding = is_mascot
	local crest_bounds = getHotspotEntry(hotspotAsset, "jersey", "team")
	local name_bounds = initData.JerseyNameVisible ~= 0 and getHotspotEntry(hotspotAsset, "jersey", "name") or no_hotspot
	local name_arccenter = getHotspotEntry(hotspotAsset, "jersey", "namearccenter")
	local frontnum_bounds = getHotspotTensAndUnits(hotspotAsset, initData.JerseyFrontNumberVisible, initData.KitNumber, "jersey", "numberfront", zero_padding)
	local backnum_bounds = getHotspotTensAndUnits(hotspotAsset, initData.JerseyBackNumberVisible, initData.KitNumber, "jersey", "numberback", zero_padding)
	local brand_bounds = getHotspotEntry(hotspotAsset, "jersey", "brand")
	local weave_tiles = getHotspotEntry(hotspotAsset, "jersey", "weave_tiles")
	local effectParams = getHotspotEntry(hotspotAsset, "jersey", "effectParams") or no_effect
	local decalEffectParams = getHotspotEntry(hotspotAsset, "jersey", "decalEffectParams") or no_effect


	-- material
	local material = item:addMaterial("jersey_mat")

	-- textures

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.ambientTexture, aoMap)

	material:addTexture(ShaderParam.normalArrayTexture, wrinkleMap)

	material:addTexture(ShaderParam.twistMaskTexture, twistMap)

	material:addTexture(ShaderParam.numberTensTexture, numberTensMap)

	material:addTexture(ShaderParam.numberUnitsTexture, numberUnitsMap)

	if SETTING.Generation >= 5 then 

		material:addTexture(ShaderParam.numberTensFrontTexture, numberTensFrontMap)

		material:addTexture(ShaderParam.numberUnitsFrontTexture, numberUnitsFrontMap)
	end


	material:addTexture(ShaderParam.taaTexture, taaMap)

	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end
	_addCrestWithHotspot(material, crestColorMap, crestCoeffMap, crestNormalMap, crest_bounds.Bounds)
	_addBrandWithHotspot(material, brandColorMap, brandCoeffMap, brandNormalMap, brand_bounds.Bounds)

	_addWeaveShaderParams(material, weaveCoeffMapArray, weaveNormalMapArray, weave_tiles.Bounds)
	_addDirtShaderParams(material, initData, dirtMap, dirtMask)

	_addEffectShaderParams(material, effectParams, decalEffectParams)


	material:addVector(ShaderParam.nameLayout, {initData.JerseyNameLayout,0,0,0}) 

	material:addVector(ShaderParam.nameColor, initData.KitNameColor)

	if initData.KitNameOutlineWidth > 0 then

		material:addVector(ShaderParam.nameOutlineColor, initData.KitNameOutlineColor)
	else

		material:addVector(ShaderParam.nameOutlineColor, {0,0,0,0})
	end


	material:addVector(ShaderParam.nameBounds, name_bounds.Bounds)

	material:addVector(ShaderParam.nameArcCenter, name_arccenter.Bounds)


	material:addVector(ShaderParam.numberTensBoundsFront, frontnum_bounds.Tens)

	material:addVector(ShaderParam.numberUnitsBoundsFront, frontnum_bounds.Units)

	material:addVector(ShaderParam.numberTensBoundsBack, backnum_bounds.Tens)

	material:addVector(ShaderParam.numberUnitsBoundsBack, backnum_bounds.Units)


	material:addVector(ShaderParam.primaryColor, _color4To3(initData.KitColorJerseyPri))

	material:addVector(ShaderParam.secondaryColor, _color4To3(initData.KitColorJerseySec))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.KitColorJerseyTer))


	material:addVector(ShaderParam.primaryNumberColor, initData.JerseyNumberColorPri)

	material:addVector(ShaderParam.secondaryNumberColor, initData.JerseyNumberColorSec)

	material:addVector(ShaderParam.tertiaryNumberColor, initData.JerseyNumberColorTer)

	-- default dry ao map. player_bp schematics can override this param based on weather setup

	-- ES conversion: not found in any SG shader, is it still in use?
	-- material:addVector(ShaderParam.ambientWetChannelSelect, jersey_wet_ao_channel_select.dry)

	-- runtime generated textures

	material:addGenTexture(ShaderParam.nameTexture, playerNameGeneratedMap)

	material:addGenTexture(ShaderParam.badgeMapTexture, badgeMap)

	material:addGenTexture(ShaderParam.coefficientTexture, coeffGeneratedMap)

	material:addGenTexture(ShaderParam.normalTexture, normalGeneratedMap)

	return item
end

-----------------------------------------------------------------------------
local function bindShoe(initData, shoe_mesh, colorMap, coeffMap, normalMap, ambientMap, dirtMap, dirtMask)
	local item = createItem("shoes", slots.shoes, initData.laneId)
	item:addMeshLodPair(lod0, shoe_mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("shoe_mat")

	-- textures

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.ambientTexture, ambientMap)

	_addDirtShaderParams(material, initData, dirtMap, dirtMask)

	-- vectors

	material:addVector(ShaderParam.primaryColor, _color4To3(initData.ShoeColorPri))

	material:addVector(ShaderParam.secondaryColor, _color4To3(initData.ShoeColorSec))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.ShoeColorTer))

	return item
end

-----------------------------------------------------------------------------
local function bindSocks(initData, args, socks_mesh, hotspotAsset,
						 colorMap, coeffMap, aoMap, normalMap, bentNormalMap, 
						 wrinkleMap, twistMap, dirtMap, dirtMask, taaMap, 
						 weaveNormalMapArray, weaveCoeffMapArray,
						 cullMapGenerated)

	local bbox_update = args.static_socks and updateBoundingBox or noBoundingBox
	local slot = initData.UseWardrobeSock ~= 0 and slots.wardrobe_socks or slots.socks

	local item = createItem("socks", slot, initData.laneId)
	item:setIncludeCullTagHashes("Socks")
	
	if initData.UseKitSock ~=0 then _addPsdTags(initData, args, item, "psd_legs") end

	item:addMeshLodPair(lod0, socks_mesh, bbox_update, playerDrawOrder, playerDrawSubOrder)

	-- hotspots
	local no_effect = {Bounds = {0,0,0,0} }
	local weave_tiles = getHotspotEntry(hotspotAsset, "socks", "weave_tiles")
	local effectParams = getHotspotEntry(hotspotAsset, "socks", "effectParams") or no_effect
	
	-- material
	local material = item:addMaterial("socks_mat")
	
	-- textures

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.ambientTexture, aoMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.normalArrayTexture, wrinkleMap)

	material:addTexture(ShaderParam.twistMaskTexture, twistMap)

	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end


	material:addTexture(ShaderParam.taaTexture, taaMap)

	-- why is this set twice?

	material:addTexture(ShaderParam.weaveNormalArrayTexture, weaveNormalMapArray)

	material:addTexture(ShaderParam.weaveCoeffArrayTexture, weaveCoeffMapArray)


	material:addGenTexture(ShaderParam.cullTexture, cullMapGenerated)
	
	_addWeaveShaderParams(material, weaveCoeffMapArray, weaveNormalMapArray, weave_tiles.Bounds)
	_addDirtShaderParams(material, initData, dirtMap, dirtMask)

	_addEffectShaderParams(material, effectParams)

	-- vectors

	material:addVector(ShaderParam.primaryColor, _color4To3(initData.KitColorSocksPri))

	material:addVector(ShaderParam.secondaryColor, _color4To3(initData.KitColorSocksSec))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.KitColorSocksTer))

	-- default dry ao map. player_bp schematics can override this param based on weather setup

	-- material:addVector(ShaderParam.ambientWetChannelSelect, jersey_wet_ao_channel_select.dry)

	return item
end

-----------------------------------------------------------------------------
local function bindGkGloves(initData, mesh, colorMap, coeffMap, normalMap)
	local item = createItem("gkglove", slots.gkglove, initData.laneId)
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("gkglove_mat")

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	return item
end

----------------------------------------------------------------------------------------------
-- underkit
local function bindUnderArms(initData, mesh,
							 colorMap, coeffMap, aoMap, normalMap, bentNormalMap,
							 wrinkleMap, twistMap, dirtMap, dirtMask,
							 taaMap, weaveNormalMapArray, weaveCoeffMapArray)
	local item = createItem("underarms", slots.underarms, initData.laneId)
	item:setIncludeCullTagHashes("WinterGear")

	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("underarms_mat")

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.ambientTexture, aoMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.normalArrayTexture, wrinkleMap)

	material:addTexture(ShaderParam.twistMaskTexture, twistMap)


	material:addTexture(ShaderParam.taaTexture, taaMap)

	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end


	material:addVector(ShaderParam.primaryColor, _color4To3(initData.KitColorJerseyPri))

	material:addVector(ShaderParam.secondaryColor, _color4To3(initData.KitColorJerseySec))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.KitColorJerseyTer))

	_addWeaveShaderParams(material, weaveCoeffMapArray, weaveNormalMapArray, nil)
	_addDirtShaderParams(material, initData, dirtMap, dirtMask)

	return item
end

-----------------------------------------------------------------------------
local function bindUnderNeck(initData, mesh, 
							 colorMap, coeffMap, aoMap, normalMap, bentNormalMap,
							 wrinkleMap, twistMap, dirtMap, dirtMask,
							 taaMap, weaveNormalMapArray, weaveCoeffMapArray)
	local item = createItem("underneck", slots.underneck, initData.laneId)
	item:setIncludeCullTagHashes("WinterGear")

	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("underneck_mat")

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.ambientTexture, aoMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.normalArrayTexture, wrinkleMap)

	material:addTexture(ShaderParam.twistMaskTexture, twistMap)
	

	material:addTexture(ShaderParam.taaTexture, taaMap)
	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end
	

	material:addVector(ShaderParam.primaryColor, _color4To3(initData.KitColorJerseyPri))

	material:addVector(ShaderParam.secondaryColor, _color4To3(initData.KitColorJerseySec))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.KitColorJerseyTer))

	_addWeaveShaderParams(material, weaveCoeffMapArray, weaveNormalMapArray, nil)
	_addDirtShaderParams(material, initData, dirtMap, dirtMask)
	
	return item
end

-----------------------------------------------------------------------------
local function bindUnderShorts(initData, args, mesh, 
							   colorMap, coeffMap, aoMap, 
							   normalMap, bentNormalMap, wrinkleMap, 
							   twistMap, dirtMap, dirtMask, taaMap, 
							   weaveNormalMapArray, weaveCoeffMapArray)
	local item = createItem("undershorts", slots.undershorts, initData.laneId)
	item:setIncludeCullTagHashes("WinterGear")
	_addPsdTags(initData, args, item, "psd_legs")

	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("undershorts_mat")

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.ambientTexture, aoMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.normalArrayTexture, wrinkleMap)

	material:addTexture(ShaderParam.twistMaskTexture, twistMap)


	material:addTexture(ShaderParam.taaTexture, taaMap)

	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end
	

	material:addVector(ShaderParam.primaryColor, _color4To3(initData.KitColorShortPri))

	material:addVector(ShaderParam.secondaryColor, _color4To3(initData.KitColorShortSec))

	material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.KitColorShortTer))

	_addWeaveShaderParams(material, weaveCoeffMapArray, weaveNormalMapArray, nil)
	_addDirtShaderParams(material, initData, dirtMap, dirtMask)

	return item
end

----------------------------------------------------------------------------------------------
-- outfit
local function _addOutfitTextureParams(material, colorMap, coeffMap, aoMap, normalMap, taaMap, 
  										weaveCoeffMap, weaveNormalMap, cullMap)

	material:addTexture(ShaderParam.colorTexture, colorMap)

	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.ambientTexture, aoMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)
	
	if (taaMap) then

		material:addTexture(ShaderParam.taaTexture, taaMap)
	end


	material:addTexture(ShaderParam.weaveCoeffArrayTexture, weaveCoeffMap)

	material:addTexture(ShaderParam.weaveNormalArrayTexture, weaveNormalMap)


	material:addTexture(ShaderParam.cullTexture, cullMap)
end

-----------------------------------------------------------------------------
local function bindTop0(initData, mesh,
						colorMap, coeffMap, aoMap, normalMap, taaMap,
						weaveCoeffMap, weaveNormalMap, cullMap, hotspotFile)
	local item = createItem("wardrobe_top_base_recolor", slots.top_base_recolor, initData.laneId)
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local effectParams = _readGenericHotspotData(hotspotFile, "top", "effectParams", {0,0,0,0})

	local material = item:addMaterial("top_clothing_mat")
	_addOutfitTextureParams(material, colorMap, coeffMap, aoMap, normalMap, taaMap, weaveCoeffMap, weaveNormalMap, cullMap)
	
	if (initData.TopBaseIsRecolorable ~= 0) then

		material:addVector(ShaderParam.primaryColor, _color4To3(initData.TopBaseColor))

		material:addVector(ShaderParam.secondaryColor, _color4To3(initData.TopBaseColor))

		material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.TopBaseColor))
	else

		material:addVector(ShaderParam.primaryColor, {1,0,0})

		material:addVector(ShaderParam.secondaryColor, {0,1,0})

		material:addVector(ShaderParam.tertiaryColor, {0,0,1})
	end

	_addEffectShaderParams(material, effectParams)

	return item
end

-----------------------------------------------------------------------------
local function bindTop1(initData, mesh,
						colorMap, coeffMap, aoMap, normalMap, taaMap,
						weaveCoeffMap, weaveNormalMap, cullMap, 
						hotspotFile, ddsCrestMap)
	local hotspotdata = _readGenericHotspotData(hotspotFile, "top", "team")
	local effectParams = _readGenericHotspotData(hotspotFile, "top", "effectParams", {0,0,0,0})

	local crest_bounds = hotspotdata.Bounds or {-1,-1,-1,-1}

	local item = createItem("wardrobe_secondlayer_recolor", slots.top_second_recolor, initData.laneId)
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("top_clothing_mat")
	_addOutfitTextureParams(material, colorMap, coeffMap, aoMap, normalMap, taaMap, weaveCoeffMap, weaveNormalMap, cullMap)


	material:addTexture(ShaderParam.crestTexture, ddsCrestMap)


	material:addVector(ShaderParam.teamCrestBounds, crest_bounds)

	if(initData.TopSecondLayerIsRecolorable ~= 0) then

		material:addVector(ShaderParam.primaryColor, _color4To3(initData.TeamColorPri))

		material:addVector(ShaderParam.secondaryColor, _color4To3(initData.TeamColorSec))

		material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.TeamColorTer))
	else

		material:addVector(ShaderParam.primaryColor, {1,0,0})

		material:addVector(ShaderParam.secondaryColor, {0,1,0})

		material:addVector(ShaderParam.tertiaryColor, {0,0,1})
	end

	_addEffectShaderParams(material, effectParams)

	return item
end

-----------------------------------------------------------------------------
local function bindBottom0(initData, mesh, 
						   colorMap, coeffMap, aoMap, normalMap, taaMap,
						   weaveCoeffMap, weaveNormalMap, cullMap, hotspotFile)
	local item = createItem("actor_bottom", slots.bottom, initData.laneId)
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local effectParams = _readGenericHotspotData(hotspotFile, "bottom", "effectParams", {0,0,0,0})

	local material = item:addMaterial("bottom_clothing_mat")
	_addOutfitTextureParams(material, colorMap, coeffMap, aoMap, normalMap, taaMap, weaveCoeffMap, weaveNormalMap, cullMap)
	
	if(initData.BottomIsRecolorable ~= 0) then

		material:addVector(ShaderParam.primaryColor, _color4To3(initData.BottomColor))

		material:addVector(ShaderParam.secondaryColor, _color4To3(initData.BottomColor))

		material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.BottomColor))
	else

		material:addVector(ShaderParam.primaryColor, {1,0,0})

		material:addVector(ShaderParam.secondaryColor, {0,1,0})

		material:addVector(ShaderParam.tertiaryColor, {0,0,1})
	end

	_addEffectShaderParams(material, effectParams)

	return item
end

-----------------------------------------------------------------------------
local function bindBottom1(initData, mesh, 
						   colorMap, coeffMap, aoMap, normalMap, taaMap,
						   weaveCoeffMap, weaveNormalMap, cullMap, hotspotFile, ddsCrestMap)
	local hotspotdata = _readGenericHotspotData(hotspotFile, "bottom", "team")
	local effectParams = _readGenericHotspotData(hotspotFile, "bottom", "effectParams", {0,0,0,0})

	local crest_bounds = hotspotdata.Bounds or {-1,-1,-1,-1}

	local item = createItem("actor_bottom_second_layer", slots.bottom_second, initData.laneId)
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("bottom_clothing_mat")
	_addOutfitTextureParams(material, colorMap, coeffMap, aoMap, normalMap, taaMap, weaveCoeffMap, weaveNormalMap, cullMap)


	material:addTexture(ShaderParam.crestTexture, ddsCrestMap)


	material:addVector(ShaderParam.teamCrestBounds, crest_bounds)

	if(initData.BottomSecondLayerIsRecolorable ~= 0) then

		material:addVector(ShaderParam.primaryColor, _color4To3(initData.BottomSecondLayerColor))

		material:addVector(ShaderParam.secondaryColor, _color4To3(initData.BottomSecondLayerColor))

		material:addVector(ShaderParam.tertiaryColor, _color4To3(initData.BottomSecondLayerColor))
	else

		material:addVector(ShaderParam.primaryColor, {1,0,0})

		material:addVector(ShaderParam.secondaryColor, {0,1,0})

		material:addVector(ShaderParam.tertiaryColor, {0,0,1})
	end

	_addEffectShaderParams(material, effectParams)

	return item
end

local function bindMouthbag(initData, args, mouthbag_mesh, colorMap, coeffMap, normalMap, bentNormalMap, sssMap)
	local item = createItem("mouthbag", slots.mouthbag, initData.laneId)
	item:setIncludeCullTagHashes("mouthbag")
	_addPsdTags(initData, args, item, "normalsmooth", "mouthbag")
	
	item:addMeshLodPair(lod0, mouthbag_mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder_Body)
	
	local mouthbagMaterial = item:addMaterial("mouthbag_mat")
	
	mouthbagMaterial:addTexture(ShaderParam.colorTexture, colorMap)
	mouthbagMaterial:addTexture(ShaderParam.coefficientTexture, coeffMap)
	mouthbagMaterial:addTexture(ShaderParam.baseNormalTexture, normalMap)
	mouthbagMaterial:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	mouthbagMaterial:addTexture(ShaderParam.sssTexture, sssMap)
	
	return item
end

-----------------------------------------------------------------------------
local function bindHead(initData, args, head_mesh, 
			colorMap, faceGenMap, normalMap, normalGenMap, bentNormalMap, 
			wrinkleNormalMap, coeffMap, coeffGenMap, aoMap, specMaskMap, specMaskGenMap,
			exertionCoeffMap, exertionNormalMap, sssMap, wrinkleMaskMap, eyeMap, isHighresFan, cullMap)

	
	local isCreatedPlayer = initData.IsCreatedPlayer ~= 0
	local isGenericPlayer = initData.HeadClass ~= 0 or args.force_generic
	
	local item = nil

	if isCreatedPlayer then
		item = createItem("caphead", slots.head, initData.laneId)
		_addPsdTags(initData, args, item, "normalsmooth", "psd")
		item:addMeshLodPair(0, head_mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder_Body)
	else
		item = createItem("head", slots.head, initData.laneId)
		_addPsdTags(initData, args, item, "normalsmooth", "psd")
		item:addMeshLodPair(0, head_mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder_Body)
	end

	local headMaterial = item:addMaterial("head_mat")
	-- head material
	if isGenericPlayer then 

		headMaterial:addGenTexture(ShaderParam.colorTexture, faceGenMap)
	else

		headMaterial:addTexture(ShaderParam.colorTexture, colorMap)
	end
	
	if normalMap ~= nil then

		headMaterial:addTexture(ShaderParam.baseNormalTexture, normalMap)
	else

		headMaterial:addGenTexture(ShaderParam.baseNormalTexture, normalGenMap)
	end

	if coeffMap ~= nil then

		headMaterial:addTexture(ShaderParam.coefficientTexture, coeffMap)
	else

		headMaterial:addGenTexture(ShaderParam.coefficientTexture, coeffGenMap)
	end

	if specMaskMap ~= nil then

		headMaterial:addTexture(ShaderParam.specmaskTexture, specMaskMap)
	else

		headMaterial:addGenTexture(ShaderParam.specmaskTexture, specMaskGenMap)
	end
	
	if isHighresFan then
		-- head is in top left quadrant of the texture atlas 

		headMaterial:addVector(ShaderParam.colorMapScaleOffset, {0.5,0.5,0,0})
	else
		
		headMaterial:addVector(ShaderParam.colorMapScaleOffset, {1,1,0,0})		
	end
	

	headMaterial:addTexture(ShaderParam.aoBlendTexture, aoMap)


	headMaterial:addTexture(ShaderParam.exertionCoeffTexture, exertionCoeffMap)

	headMaterial:addTexture(ShaderParam.exertionNormalTexture, exertionNormalMap)

	headMaterial:addTexture(ShaderParam.sssTexture, sssMap)
	

	headMaterial:addTexture(ShaderParam.wrinkleMaskTexture, wrinkleMaskMap)

	headMaterial:addTexture(ShaderParam.wrinkleNormalTexture, wrinkleNormalMap)
	
	if bentNormalMap then

		headMaterial:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end
	

	headMaterial:addVector(ShaderParam.flushness_color, initData.FlushnessColor)
	if cullMap then
		headMaterial:addTexture(ShaderParam.cullTexture, cullMap)
	end
	
	-- eye material
	local eyecolor = initData.IsMannequin~=0 and 0 or initData.EyeColor
	eyecolor = math.min(eyecolor + 1, #EYE_COLOR_LIST)
	local eyeColorRGB = EYE_COLOR_LIST[eyecolor]
	local eyesMaterial = item:addMaterial("eyes_mat")

	eyesMaterial:addTexture(ShaderParam.colorTexture, eyeMap)

	eyesMaterial:addVector(ShaderParam.eyeColor, eyeColorRGB)





	return item
end

-----------------------------------------------------------------------------
local function bindSculptControlShapes(initData, args, controlShapes)
	local item = createItem("control_shapes", slots.sculptshapes, initData.laneId)
	_addPsdTags(initData, args, item, "psd")
	local controlShapesArray = getArrayFromBatch(controlShapes)
	for i = 1, #controlShapesArray do
		item:addMeshLodPair(lod0, controlShapesArray[i], noBoundingBox, playerDrawOrder, playerDrawSubOrder)
	end
	return item
end

-----------------------------------------------------------------------------
local function bindHairItem(initData, args, hair_mesh)
	local item = createItem("card_hair", slots.cardhair, initData.laneId)
	item:setIncludeCullTagHashes("card_hair")
	-- for non cloth hair use "psd" tag for psd wraping
	_addPsdTags(initData, args, item, "psd", "card_hair")
	item:addMeshLodPair(0, hair_mesh, noBoundingBox, playerDrawOrder_Default, playerDrawSubOrder_Hair)
	_addHairMaterials(item, initData, args)
	return item
end

-- hair cap item
local function bindHaircapItem(initData, args, haircap_mesh)
	local item = createItem("haircap", slots.haircap, initData.laneId)
	item:setIncludeCullTagHashes("haircap")
	_addPsdTags(initData, args, item, "psd", "haircap")
	-- not all haircaps have embedded lods, instead of using lod0 when lower lod is chosen let use no lod at all
	local lodsRequired = 2
	item:addMeshWithEmptyLods(haircap_mesh, lodsRequired, noBoundingBox, playerDrawOrder_Default, playerDrawSubOrder_Haircap)
	_addHairMaterials(item, initData, args)
	return item
end

-- hair accessory item
local function bindHairAccessoryItem(initData, args, hair_accessory_mesh)
	local item = createItem("hair_accessory", slots.hairacc, initData.laneId)
	item:setIncludeCullTagHashes("hair_accessory")
	_addPsdTags(initData, args, item, "psd", "hair_accessory")
	item:addMeshLodPair(lod0, hair_accessory_mesh, noBoundingBox, playerDrawOrder_Default, playerDrawSubOrder_Haircap)
	item:addMaterial("accessory_mat")
	return item
end

local function bindStrandHairItem(initData, args, slot_name, name, asset)
	local item = createItem(name, slot_name, initData.laneId)
	item:setIncludeCullTagHashes(name)
	item:setTagHashes(name)
	item:addMeshLodPair(lod0, asset, noBoundingBox, playerDrawOrder_Default, playerDrawSubOrder_Hair)

	local color_pri, color_sec, color_ter
	if slot_name == slots.strandbeard then
		color_pri, color_sec, color_ter = _getFacialHairColors(initData, args)
	elseif  slot_name == slots.strandeyebrow then 
		color_pri, color_sec, color_ter = _getEyebrowColors(initData, args)
	else
		color_pri, color_sec, color_ter = _getHairColors(initData, args)
	end

	-- strand hair don't have real material, use a fake one to pass parameters
	-- the name and parameters are hardcoded in AppearanceStrandHairPart.cpp
	local mat = item:addMaterial("strandhair_mat")
	mat:addVector("priColor", color_pri)
	mat:addVector("secColor", color_sec)
	mat:addVector("terColor", color_ter)


	-- future support if needed
	--[[
	mat:addVector("eccentricity", {0.1, 0, 0, 0})
	mat:addVector("eccentricityRandomization", {0.1, 0, 0, 0})
	mat:addVector("rootToTipBlendStart", {0.1, 0, 0, 0})
	mat:addVector("rootToTipBlendEnd", {0.9, 0, 0, 0})
	mat:addVector("iblShadowingStrength", {0.3, 0, 0, 0})
	mat:addVector("colorBlendOffsetRandomization", {0.2, 0, 0, 0})
	mat:addVector("smoothness", {0.2, 0, 0, 0})
	mat:addVector("radialSmoothness", {0.3, 0, 0, 0})
	--]]
	
	return item
end

-----------------------------------------------------------------------------
local function _bindWarmupBib(initData, mesh, colorMap)
	local home_clr = {0.78, 0.29, 0.11, 0}
	local away_clr = {0.83, 0.72, 0.03, 0} 
	local custom_clr = {1, 0, 0, 0}
	local team_clr = initData.TeamSide == 0 and home_clr or away_clr
	local clr0 = initData.HasCustomBib == 0 and team_clr or custom_clr

	local item = createItem("warmup_bib", slots.warmup_bib, initData.laneId)
	item:setTagHashes("warmup_bib")
	item:setIncludeCullTagHashes("WarmupBib")
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local mat = item:addMaterial("bib_mat")

	mat:addTexture(ShaderParam.colorTexture, colorMap)

	mat:addVector(ShaderParam.primaryColor, _color4To3(clr0))

	mat:addVector(ShaderParam.secondaryColor, {0,1,0})

	mat:addVector(ShaderParam.tertiaryColor,  {0,0,1})

	return item
end

-----------------------------------------------------------------------------
local function _bindWarmupTop(initData, mesh,
		colorMap, coeffMap, aoMap, normalMap, taaMap,
		weaveCoeffMap, weaveNormalMap, cullMap, 
		hotspotFile, ddsCrestMap, colors, isEquipped)
	local hotspotdata = _readGenericHotspotData(hotspotFile, "top", "team")
	local crest_bounds = hotspotdata.Bounds or {-1,-1,-1,-1}

	local item = createItem("warmup_jacket", slots.warmup_jacket, initData.laneId)
	
	if isEquipped == false then
		item:setIncludeCullTagHashes("WarmupGear","WarmupTop","WarmupGearNotEquipped")
	else
		item:setIncludeCullTagHashes("WarmupGear", "WarmupTop" )
	end	
	
	item:setExcludeCullTagHashes("JerseyCloth", "JerseyNoCloth", "WinterGear", "Arms")
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("top_clothing_mat")
	_addOutfitTextureParams(material, colorMap, coeffMap, aoMap, normalMap, taaMap, weaveCoeffMap, weaveNormalMap, cullMap)

	if( anthemJacket[initData.TeamId] == nil ) then
	material:addVector(ShaderParam.primaryColor, _remapToPBR(colors[1]))

	material:addVector(ShaderParam.secondaryColor, _remapToPBR(colors[2]))

	material:addVector(ShaderParam.tertiaryColor, _remapToPBR(colors[3]))


	material:addTexture(ShaderParam.crestTexture, ddsCrestMap)

	material:addVector(ShaderParam.teamCrestBounds, crest_bounds)
	end
	return item
end

-----------------------------------------------------------------------------
local function _bindWarmupBottom(initData, mesh,
		colorMap, coeffMap, aoMap, normalMap, taaMap,
		weaveCoeffMap, weaveNormalMap, cullMap, 
		hotspotFile, ddsCrestMap, colors, isEquipped)
	local hotspotdata = _readGenericHotspotData(hotspotFile, "bottom", "team")
	local crest_bounds = hotspotdata.Bounds or {-1,-1,-1,-1}

	local item = createItem("warmup_pants", slots.warmup_pants, initData.laneId)	

	if isEquipped == false then	
		item:setIncludeCullTagHashes("WarmupGear","WarmupBottom", "WarmupGearNotEquipped")
	else
		item:setIncludeCullTagHashes("WarmupGear", "WarmupBottom")	
	end
	
	item:setExcludeCullTagHashes("Legs", "ShortsCloth", "ShortsNoCloth", "GkPants", "Socks")
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("bottom_clothing_mat")
	_addOutfitTextureParams(material, colorMap, coeffMap, aoMap, normalMap, taaMap, weaveCoeffMap, weaveNormalMap, cullMap)

	if( anthemPants[initData.TeamId] == nil ) then
	material:addVector(ShaderParam.primaryColor, _remapToPBR(colors[1]))

	material:addVector(ShaderParam.secondaryColor, _remapToPBR(colors[2]))

	material:addVector(ShaderParam.tertiaryColor, _remapToPBR(colors[3]))


	material:addTexture(ShaderParam.crestTexture, ddsCrestMap)

	material:addVector(ShaderParam.teamCrestBounds, crest_bounds)
	end
	return item
end


local function _bindAccessory(initData, args, idx, accessory, mesh, colorMap, normalMap, coeffMap, aoMap, weaveNormalMap, weaveCoeffMap, tag)
	local name, slot
	if initData.UseKitAccessory then
		name = string.format("accessory_%d", idx)
		slot = accessory_slots[idx]
	else
		name = string.format("wardrobe_accessory_%d", idx)
		slot = wardrobe_accessory_slots[idx]
	end

	local item = createItem(name, slot, initData.laneId)
	item:setIncludeCullTagHashes(string.format("AccessorySlot%d", idx))
	
	if tag then
		item:setTagHashes(tag)
	end
		
	 -- add psd to facemasks
	local model = accessory.AccessoryModel
	if model > 149 and model < 161 then
		_addPsdTags(initData, args, item, "psd")
	end
	
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder_Accessory)

	local mat = item:addMaterial("accessory_mat")

	mat:addTexture(ShaderParam.colorTexture, colorMap)

	mat:addTexture(ShaderParam.coefficientTexture, coeffMap)

	mat:addTexture(ShaderParam.normalTexture, normalMap)

	if aoMap then

		mat:addTexture(ShaderParam.ambientTexture, aoMap)
	end

	if weaveNormalMap then

		mat:addTexture(ShaderParam.weaveNormalArrayTexture, weaveNormalMap)

		mat:addTexture(ShaderParam.weaveCoeffArrayTexture, weaveCoeffMap)
	end


	mat:addVector(ShaderParam.primaryColor, _color4To3(accessory.AccessoryColorArgb))

	return item
end

local function buildRefAccessory(laneId, tag, mesh, colorMap, normalMap, coeffMap)
	local name = getAssetName(mesh)
	local slot = "content/common/configs/slots/" .. tag

	local item = createItem(name, slot, laneId)
	item:setIncludeCullTagHashes(tag)
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder_Accessory)

	local mat = item:addMaterial("accessory_mat")

	mat:addTexture(ShaderParam.colorTexture, colorMap)

	mat:addTexture(ShaderParam.normalTexture, normalMap)

	mat:addTexture(ShaderParam.coefficientTexture, coeffMap)

	return item
end

-----------------------------------------------------------------------------
local function bindPlayerBeard(initData, args, is_cap, mesh, colorMap, coeffMap)
	local name = is_cap and "beard_cap" or "beard"
	--local slot = is_cap and slots.haircap or slots.hair_nocloth
	local slot = is_cap and slots.beardcap or slots.beard
	local draw_order = is_cap and playerDrawSubOrder_Haircap or playerDrawSubOrder_Hair

	local item = createItem(name, slot, initData.laneId)
	_addPsdTags(initData, args, item, "psd", name)
	
	local lodsRequired = 2
	item:addMeshWithEmptyLods(mesh, lodsRequired, noBoundingBox, playerDrawOrder_Default, draw_order)

	_addFacialHairMaterials(item, initData, args)
	return item
end

local function bindeyelash(initData, eyelash_mesh)
	local item = createItem("eyelash", slots.eyelash, initData.laneId)
	-- don't draw eyelashes for lod1,2
	local lodsRequired = 2
	item:addMeshWithEmptyLods(eyelash_mesh, lodsRequired, noBoundingBox, playerDrawOrder_Default, playerDrawSubOrder_Hair)
	return item
end

-----------------------------------------------------------------------------
local function bindShadowItem(initData, shadow_mesh, importance_mesh)
	-- use bounding box calculations for planar otherwise they will be invisible
	local item = createItem("shadow", slots.shadow, initData.laneId)
	item:addMeshLodPair(lod0, shadow_mesh, updateBoundingBox, playerDrawOrder_Default)
	item:addMeshLodPair(lod0, importance_mesh, noBoundingBox, playerDrawOrder_Default)
	return item
end

-----------------------------------------------------------------------------
-- hotspots have a blendmode vector with the blendmode 
-- value for 3 skintone ranges

local function _getBlendMode(skintone, blendvalues)
	local bm = blendvalues.Bounds or {0,0,0,0}
	local blendmode=0
	if skintone <=3 then 
		blendmode = bm[1]  -- light
	elseif skintone < 8 then
		blendmode = bm[2]  -- medium
	else
		blendmode = bm[3]  -- dark
	end
	return math.floor(blendmode)
end


-----------------------------------------------------------------------------
-- texture composition functions
local function compositeJerseyWithBadges(initData, hotspotAsset, competitionHotspot, desc, isNormalMap,
										 badgeBakeMaskMap, baseLayerMap, leftBadgeMap, rightBadgeMap, middleBadgeMap, armbandMap)

	local llongHotspot = getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeLeftID, "leftsleevelong")
	local lshortHotspot = getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeLeftID, "leftsleeveshort")
	local rlongHotspot = getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeRightID, "rightsleevelong")
	local rshortHotspot = getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeRightID, "rightsleeveshort")
	local middleHotspot = getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeMiddleID, "center")
	local armbandHotspot = getHotspotEntry(hotspotAsset, "jersey", "armband")

	local defaultHotspot = {0, 0, 1.0, 1.0}
	local rotation = 0.0

	-- generate unique texture id
	local inputs = {
		getAssetName(baseLayerMap), getAssetName(leftBadgeMap), getAssetName(rightBadgeMap), 
		getAssetName(middleBadgeMap), getAssetName(armbandMap)
	}
	local texture_id = table.concat(inputs, "|")

	local mips, compress = 0, true

	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(badgeBakeMaskMap, "badgeBakeMaskMap")
	cryoResourceMap:addTexture(baseLayerMap, "baseLayerMap")
	cryoResourceMap:addTexture(leftBadgeMap, "leftBadgeMap")
	cryoResourceMap:addTexture(rightBadgeMap, "rightBadgeMap")
	cryoResourceMap:addTexture(middleBadgeMap, "middleBadgeMap")
	cryoResourceMap:addTexture(armbandMap, "armbandMap")

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "baseLayerMap")
	cryoLayer:setColorMask(true, true, true, false)
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)

	-- from schematics: For now, Disabling these inputs so they won't be stamped onto the Normal Map, as Normal Map stamping isn't working with the kit badge mask.
	if isNormalMap == false then
		local maskedGroup = cryoRecipe:addGroupLayer(nil, "badges")
		maskedGroup:setBlending(enum.CryoBlendMode_GpuCustomBlend, 
			enum.RenderBlendMode_One, enum.RenderBlendMode_InvSourceAlpha, enum.RenderBlendOp_Add,
			enum.RenderBlendMode_One, enum.RenderBlendMode_Zero, enum.RenderBlendOp_Add)
		maskedGroup:setMaskTexture("badgebakemaskmap")
		maskedGroup:setMaskMode(enum.CryoTextureMaskMode_Stencil)

		cryoLayer = maskedGroup:addTextureLayer("leftBadgeMap")
		cryoLayer:setLegacyPlacement(llongHotspot.Bounds, llongHotspot.Rotation)

		cryoLayer = maskedGroup:addTextureLayer("leftBadgeMap")
		cryoLayer:setLegacyPlacement(lshortHotspot.Bounds, lshortHotspot.Rotation)

		cryoLayer = maskedGroup:addTextureLayer("rightBadgeMap")
		cryoLayer:setLegacyPlacement(rlongHotspot.Bounds, rlongHotspot.Rotation)

		cryoLayer = maskedGroup:addTextureLayer("rightBadgeMap")
		cryoLayer:setLegacyPlacement(rshortHotspot.Bounds, rshortHotspot.Rotation)

		cryoLayer = maskedGroup:addTextureLayer("middleBadgeMap")
		cryoLayer:setLegacyPlacement(middleHotspot.Bounds, middleHotspot.Rotation)

		cryoLayer = maskedGroup:addTextureLayer("armbandMap")
		cryoLayer:setLegacyPlacement(armbandHotspot.Bounds, armbandHotspot.Rotation)
	end

	local cryoCompositor = createCryoTextureCompositor("JerseyWithBadgesColor", 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

local function compositePlayerName(initData, fontAsset)
	local width, height, mips = 512, 128, 0
	local font_format = enum.RasterizedTextureFormat_RGBA

	local texture_id = string.format("playername_%d_%s_%s_%d", initData.PlayerId, initData.KitName, getAssetName(fontAsset), initData.KitNameOutlineWidth)
	local compositor = createTextureCompositor(texture_id, width, height, mips, true, enum.RenderFormat_BC3_SRGB, initData.laneId, "compositePlayerName")
	compositor:setText(fontAsset, initData.KitName, font_format, initData.KitNameOutlineWidth)
	--compositor:setText(fontAsset, "caÃ±Ã³n", font_format)
	return compositor:rasterize()
end

local function compositeClothRigidMask(initData, hotspotAsset, competitionHotspot, compositorDesc, maskWhite)
	
	local no_hotspot = { Bounds = {-1, -1, -1, -1}, Rotation = 0 }
	local max_hotspot_uv  = {0.15, 0.3}	--discard hotspots near jersey waist to avoid conflict with shorts

	local mask_groups = {}

	-- standard hotspots
	if initData.JerseyBadgeLeftID ~= 0 then
		if initData.JerseySleeveLength == 0 then
			table.insert(mask_groups, {getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeLeftID, "leftsleeveshort")})
		else
			table.insert(mask_groups, {getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeLeftID, "leftsleevelong")})
		end
	end
	if initData.JerseyBadgeRightID ~= 0 then
		if initData.JerseySleeveLength == 0 then
			table.insert(mask_groups, {getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeLeftID, "rightsleeveshort")})
		else
			table.insert(mask_groups, {getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeLeftID, "rightsleevelong")})
		end
	end
	if initData.JerseyBadgeMiddleID ~= 0 then
		table.insert(mask_groups, {getPlayerCompetitionHotspot(competitionHotspot, hotspotAsset, initData.JerseyBadgeMiddleID, "center")})
	end
	table.insert(mask_groups, {getHotspotEntry(hotspotAsset, "jersey", "armband")}) 
	table.insert(mask_groups, {getHotspotEntry(hotspotAsset, "jersey", "team")}) 
	table.insert(mask_groups, {getHotspotEntry(hotspotAsset, "jersey", "brand")})

	-- numeric tens and units hotspots
	local numbers_list = {}
	table.insert(numbers_list, getHotspotTensAndUnits(hotspotAsset, initData.JerseyFrontNumberVisible, initData.KitNumber, "jersey", "numberfront"))
	table.insert(numbers_list, getHotspotTensAndUnits(hotspotAsset, initData.JerseyBackNumberVisible, initData.KitNumber, "jersey", "numberback"))

	for _,numbers in ipairs(numbers_list) do
		local group_hotspots = {}
		table.insert(group_hotspots, { Bounds = numbers.Tens, Rotation = 0})
		table.insert(group_hotspots, { Bounds = numbers.Units, Rotation = 0})
		table.insert(mask_groups, group_hotspots)
	end

	-- player name arc segmented hotspots
	local nameHotspot= initData.JerseyNameVisible ~= 0 and getHotspotEntry(hotspotAsset, "jersey", "name") or no_hotspot
	local nameArcCenterHotspot = initData.JerseyNameVisible ~= 0 and getHotspotEntry(hotspotAsset, "jersey", "namearccenter") or no_hotspot
	if initData.JerseyNameLayout ~= 0 then
		table.insert(mask_groups, segmentArcRotatedHotspot(nameHotspot.Bounds, nameArcCenterHotspot.Bounds, 6))
	else
		table.insert(mask_groups, {nameHotspot})
	end

	assert(#mask_groups < 256)

	-- texture compositor
	local mips, compress = 1, true

	local cryoResourceMap = createCryoTextureResourceMap()
	local cryoRecipe = createCryoTextureRecipe()
	local cryoCompositor = createCryoTextureCompositor("ClothRigidMaskJersey", 0, compositorDesc.width, compositorDesc.height, mips, compress, compositorDesc.format, initData.laneId)

	cryoResourceMap:addTexture(maskWhite, "maskwhite")

	for index, hotspots in ipairs(mask_groups) do
		local r = index/ 255.0
		local recolor = { r, 0, 0, 1 }

		for _, hotspot in ipairs(hotspots) do
			local hotspot_points = {}
			hotspot_points[1] = {hotspot.Bounds[1], hotspot.Bounds[2]}
			hotspot_points[2] = {hotspot.Bounds[3], hotspot.Bounds[2]}
			hotspot_points[3] = {hotspot.Bounds[1], hotspot.Bounds[4]}
			hotspot_points[4] = {hotspot.Bounds[3], hotspot.Bounds[4]}
			
			local clamped = false
			for _, pt in ipairs(hotspot_points) do
				if (pt[1] > 0.5-max_hotspot_uv[1] and pt[1] < 0.5+max_hotspot_uv[1]) and (pt[2] < 0.5-max_hotspot_uv[2] or pt[2] > 0.5+max_hotspot_uv[2]) then
					clamped = true
					break
				end
			end
					
			if not clamped then
				local cryoLayer = cryoRecipe:addTextureLayer(nil, "maskwhite")
				cryoLayer:setLegacyPlacement(hotspot.Bounds, hotspot.Rotation)
				cryoLayer:setRecolorMode(enum.CryoRecolorMode_Constant)
				cryoLayer:setPrimaryColor(recolor)
			end
		end
	end

	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

local function compositeFacePaint(initData, colorMap, facepaintAsset)
	local full_hs = { Bounds = {0, 0, 1.0, 1.0}, Rotation = 0.0 }
	local face_hs= { Bounds = {0, 0, 0.5, 0.5}, Rotation = 0.0 } -- top-left quadrant
	
	local mips, compress, alpha = 0, true, 1.0

	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(colorMap, "colorMap")
	cryoResourceMap:addTexture(facepaintAsset, "facepaintAsset")

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "colorMap")
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "facepaintAsset")
	cryoLayer:setLegacyPlacement(face_hs.Bounds,face_hs.Rotation)

	local cryoCompositor = createCryoTextureCompositor("FacePaintColor", 0, 1024, 1024, mips, compress, enum.RenderFormat_BC1_SRGB, initData.laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-------------------------------------------------------------------------------------
--local function _compositeFaceSkMap(initData, args, surfacecavitymap, surfaceambientmap, browcolormap, browambientmap, facialhaircolormap, facialhairambientmap, torsocoeffmap)
local function _compositeFaceSkMap(initData, args, 
	surface_cavity_batch, surface_ambient_batch, surface_masks_batch, 
	browcolormap, browambientmap, facialhaircolormap, facialhairambientmap,
	scalpmap, torsocoeffmap)
	
	local mips, compress = 0, true
	local desc = FaceSpecMaskCompositorDesc
	local colorEncoding = enum.CryoColorEncoding_Linear			
	local texture_uid = table.concat({"gen_face_specmask", initData.PlayerId}, "|")
	local cavity_to_specmask_level = {0.05, 0.51, 1.00, 0.50, 0.97}
	local cryoResourceMap = createCryoTextureResourceMap()
	--cryoResourceMap:addTexture(surfacecavitymap, "surface_cavity_layer")
	--cryoResourceMap:addTexture(surfaceambientmap, "surface_ambient_layer")
	cryoResourceMap:addTexture(browcolormap, "brow_color_layer")
	cryoResourceMap:addTexture(browambientmap, "brow_ambient_layer")
	cryoResourceMap:addTexture(facialhaircolormap, "facialhair_color_layer")
	cryoResourceMap:addTexture(facialhairambientmap, "facialhair_ambient_layer")
	cryoResourceMap:addTexture(torsocoeffmap, "torso_coeff_layer")
	if scalpmap then
		cryoResourceMap:addTexture(scalpmap, "scalp_layer")
	end

	local surface_cavity_array = getArrayFromBatch(surface_cavity_batch)
	local surface_ambient_array = getArrayFromBatch(surface_ambient_batch)
	local surface_masks_array = getArrayFromBatch(surface_masks_batch)
	local i
	
	for i = 1, #surface_cavity_array do
		cryoResourceMap:addTexture(surface_cavity_array[i], "surface_cavity_"..i)
		cryoResourceMap:addTexture(surface_ambient_array[i], "surface_ambient_"..i)
		cryoResourceMap:addTexture(surface_masks_array[i], "mask_"..i)
	end

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer

	for i = 1, #surface_cavity_array do
		cryoLayer = cryoRecipe:addTextureLayer(nil, "surface_cavity_"..i)
		cryoLayer:setMaskTexture("mask_"..i)
		cryoLayer:setLevelAdjustment(unpack(cavity_to_specmask_level))
		
		-- multiply ambient occlusion 60%
		cryoLayer = cryoRecipe:addTextureLayer(nil, "surface_ambient_"..i)
		cryoLayer:setMaskTexture("mask_"..i)
		cryoLayer:setBlending(enum.CryoBlendMode_Multiply)
		cryoLayer:setAlpha(0.6)
	end

	cryoLayer = cryoRecipe:addTextureLayer(nil, "brow_color_layer")
	cryoLayer:setTextureSwizzleMask(enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_One)
	-- invert by level
	cryoLayer:setLevelAdjustment(0.000, 1.000, 1.000, 1.000, 0.000)
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)
		
	
	cryoLayer = cryoRecipe:addTextureLayer(nil, "brow_ambient_layer")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)
	
	cryoLayer = cryoRecipe:addTextureLayer(nil, "facialhair_color_layer")
	cryoLayer:setTextureSwizzleMask(enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_One)
	-- invert by level
	cryoLayer:setLevelAdjustment(0.000, 1.000, 1.000, 1.000, 0.000)
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)
		
	cryoLayer = cryoRecipe:addTextureLayer(nil, "facialhair_ambient_layer")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	if scalpmap then
		cryoLayer = cryoRecipe:addTextureLayer(nil, "scalp_layer")
		cryoLayer:setTextureSwizzleMask(enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_A, enum.CryoTextureColorChannel_One)
		-- invert by levels
		cryoLayer:setLevelAdjustment(0.000, 1.000, 1.000, 1.000, 0.000)
		cryoLayer:setBlending(enum.CryoBlendMode_Multiply)
	end	
			
	-- Torso mask
	cryoLayer = cryoRecipe:addTextureLayer(nil, "torso_coeff_layer")
	
	local cryoCompositor = createCryoTextureCompositor(texture_uid, 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	cryoCompositor:setColorEncoding(colorEncoding)
	
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-------------------------------------------------------------------------------------
local function _compositeFaceNormalMap(initData, args, torsonormalmap, surfacenormalmaskmap,
	surface_normal_batch, surface_masks_batch, surface_weights, 
	secondary_forms_batch, secondary_forms_weights)


	local mips, compress = 0, true
	local desc = FaceNormalCompositorDesc
	local colorEncoding = enum.CryoColorEncoding_NormalMap			
	
	local texture_uid = table.concat({"gen_face_normal", initData.PlayerId}, "|")

	
	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(torsonormalmap, "torso_normal_layer")
	cryoResourceMap:addTexture(surfacenormalmaskmap, "surface_normal_mask")


	local surface_array = getArrayFromBatch(surface_normal_batch)
	local masks_array = getArrayFromBatch(surface_masks_batch)

	for i = 1, #surface_array do
		cryoResourceMap:addTexture(masks_array[i], "mask_"..i)
		cryoResourceMap:addTexture(surface_array[i], "surface_"..i)
	end

	local secondary_forms_array = getArrayFromBatch(secondary_forms_batch)
	
	for i = 1, #secondary_forms_array do
		cryoResourceMap:addTexture(secondary_forms_array[i], "secondaryform_"..i)
	end
	
	local cryoRecipe = createCryoTextureRecipe()
	
	-- torso normal as base
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "torso_normal_layer")

	-- masked group layer
	local cryoSkinNormalGroup = cryoRecipe:addGroupLayer(nil, "surfacenormalgroup")
	cryoSkinNormalGroup:setMaskTexture("surface_normal_mask")
	cryoSkinNormalGroup:setMaskMode(enum.CryoTextureMaskMode_Stencil)
	
	for i = 1, #surface_array do
		cryoLayer = cryoSkinNormalGroup:addTextureLayer("surface_".. i)
		cryoLayer:setMaskTexture("mask_".. i)
		cryoLayer:setMaskMode(enum.CryoTextureMaskMode_Stencil)
		cryoLayer:setAlpha(surface_weights[i])
		cryoLayer:setBlending(enum.CryoBlendMode_UDN_Normal_Blending)
	end

	for i = 1, #secondary_forms_array do
		cryoLayer = cryoSkinNormalGroup:addTextureLayer("secondaryform_"..i)
		cryoLayer:setAlpha(secondary_forms_weights[i])
		cryoLayer:setBlending(enum.CryoBlendMode_UDN_Normal_Blending)
	end
	
	local cryoCompositor = createCryoTextureCompositor(texture_uid, 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	cryoCompositor:setColorEncoding(colorEncoding)
	
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-------------------------------------------------------------------------------------
local function _compositeFaceMap(initData, args, 
		skinmap, skinbasemap, skincomplexionmap, skinvariationmap, eyedetailmap, makeupmap, torsomap, 
		mouthbagmap, skinmaskmap, lipsmaskmap, surfacecavitymap, 
		facialhaircolormap, facialhairambientmap, browmap, browambientmap, scalpmap, hairlinemap, 
		tattoomap, hotspot_file)

	local full_hs= { Bounds = {0, 0, 1.0, 1.0}, Rotation = 0 }
	
	local tattoo = _readGenericHotspotData(hotspot_file, "head", "backneck")
	local blendvalues = _readTattooBlendModeData(hotspot_file, "head", "blendmode")
	
	local blendmode = _getBlendMode(initData.HeadSkinToneType, blendvalues)
	
	local eyebrowcolor_pri,	eyebrowcolor_sec,	eyebrowcolor_ter =  _getEyebrowColors(initData, args)
	local facialhaircolor_pri, facialhaircolor_sec, facialhaircolor_ter =  _getFacialHairColors(initData, args)
	local haircolor_pri, haircolor_sec, haircolor_ter  = _getHairColors(initData, args)


	local facial_pk_pri = _packUByte4N(facialhaircolor_pri)
	local facial_pk_sec = _packUByte4N(facialhaircolor_sec)
	local facial_pk_ter = _packUByte4N(facialhaircolor_ter)
	local hair_pk_sec   = _packUByte4N(haircolor_sec)
	
	local mips, compress = 0, true
	local desc = FaceCompositorDesc
	local texture_uid = table.concat({"gen_face_normal", initData.PlayerId}, "|")

	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(skinbasemap, "skin_base_layer")
	cryoResourceMap:addTexture(skincomplexionmap, "skin_complexion_layer")
	cryoResourceMap:addTexture(skinvariationmap, "skin_variation_layer")
	cryoResourceMap:addTexture(surfacecavitymap, "skin_cavity_layer")
	cryoResourceMap:addTexture(eyedetailmap, "eye_detail_layer")
	cryoResourceMap:addTexture(makeupmap, "makeup_layer")
	cryoResourceMap:addTexture(torsomap, "torso_layer")
	cryoResourceMap:addTexture(mouthbagmap, "mouthbag_layer")
	cryoResourceMap:addTexture(skinmaskmap, "skin_recolor_mask")
	cryoResourceMap:addTexture(lipsmaskmap, "lips_base_layer")

	cryoResourceMap:addTexture(tattoomap, "tattoo_layer")
	cryoResourceMap:addTexture(facialhaircolormap, "facialhair_layer")
	cryoResourceMap:addTexture(facialhairambientmap, "facialhair_ambient_layer")

	cryoResourceMap:addTexture(browmap, "brow_layer")
	cryoResourceMap:addTexture(browambientmap, "brow_ambient_layer")

	if scalpmap then
	 	cryoResourceMap:addTexture(scalpmap, "scalp_layer")
	elseif hairlinemap then
		cryoResourceMap:addTexture(hairlinemap, "hairline_layer")
	end
		
	-- HSV/LEVELS for Cryo Texture Comp


	local skinToneType = initData.IsMannequin~=0 and 1 or args.skintone + 1
	-- adjust complexion strength based on Age. Max complexion at age 25. The strength is clamped from 0 to 1 in the code.
	local complexionStrength = args.playerAge / 25.0
	local lipcolor = math.min(args.lipcolor + 1, #PLAYER_LIPCOLOR_HSL_LIST)
	
	local skinHSL = PLAYER_SKINTONE_MALE_HSL_LIST[skinToneType]
	local skinLevel = PLAYER_SKINTONE_MALE_LEVEL_LIST[skinToneType]
	local lipsHSL = PLAYER_LIPCOLOR_HSL_LIST[lipcolor]
	local lipsLevel = PLAYER_LIPCOLOR_LEVEL_LIST[lipcolor]
	local cryoRecipe = createCryoTextureRecipe()

	
	-- BEGIN SKINTONE RECOLOR GROUP

	local cryoSkintoneGroup = cryoRecipe:addGroupLayer(nil, "skintonegroup") -- rename lipsmask to skintonemask
	cryoSkintoneGroup:setMaskTexture("skin_recolor_mask")
	cryoSkintoneGroup:setMaskMode(enum.CryoTextureMaskMode_LimitAdjustments)

	cryoSkintoneGroup:setHslParams(skinHSL)
	cryoSkintoneGroup:setLevelAdjustment(unpack(skinLevel))
	
	local cryoLayer = cryoSkintoneGroup:addTextureLayer("skin_base_layer")
		
	cryoLayer = cryoSkintoneGroup:addTextureLayer("skin_complexion_layer")
	cryoLayer:setAlpha(complexionStrength)
	
	cryoLayer = cryoSkintoneGroup:addTextureLayer("skin_variation_layer")
	cryoLayer:setAlpha(PLAYER_SKIN_LAYER_OPACITY_LIST[skinToneType])
	
	cryoLayer = cryoSkintoneGroup:addTextureLayer("eye_detail_layer")
	cryoLayer:setAlpha(PLAYER_SKIN_LAYER_OPACITY_LIST[skinToneType])

	cryoLayer = cryoSkintoneGroup:addTextureLayer("skin_cavity_layer")
	cryoLayer:setTextureSwizzleMask(enum.CryoTextureColorChannel_R, enum.CryoTextureColorChannel_R, enum.CryoTextureColorChannel_R, enum.CryoTextureColorChannel_One)
	cryoLayer:setBlending(enum.CryoBlendMode_Overlay)
	cryoLayer:setAlpha(0.125)


	cryoLayer = cryoSkintoneGroup:addTextureLayer("torso_layer")
	cryoLayer:setBlending(enum.CryoBlendMode_LinearAlphaBlend,
		enum.RenderBlendMode_SourceAlpha, enum.RenderBlendMode_InvSourceAlpha, enum.RenderBlendOp_Add,
		enum.RenderBlendMode_One, enum.RenderBlendMode_One, enum.RenderBlendOp_Add)

	cryoLayer = cryoSkintoneGroup:addTextureLayer("mouthbag_layer")
	cryoLayer = cryoSkintoneGroup:addTextureLayer("makeup_layer")
	
	-- END SKINTONE RECOLOR GROUP
	
	cryoLayer = cryoRecipe:addTextureLayer(nil, "lips_base_layer")
	cryoLayer:setHslParams(lipsHSL)
	cryoLayer:setLevelAdjustment(unpack(lipsLevel))
	
	cryoLayer = cryoRecipe:addTextureLayer(nil, "tattoo_layer")
	cryoLayer:setLegacyPlacement(tattoo.Bounds, tattoo.Rotation)
	cryoLayer:setBlending(enum.CryoBlendMode_LinearAlphaBlend)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "facialhair_layer")
	cryoLayer:setBlending(enum.CryoBlendMode_LinearAlphaBlend)
	cryoLayer:setRecolorMode(enum.CryoRecolorMode_Tricolor)
	cryoLayer:setPrimaryColor(facialhaircolor_pri)
	cryoLayer:setSecondaryColor(facialhaircolor_sec)
	cryoLayer:setTertiaryColor(facialhaircolor_ter)
	
	cryoLayer = cryoRecipe:addTextureLayer(nil, "facialhair_ambient_layer")
	cryoLayer:setTextureSwizzleMask(
			enum.CryoTextureColorChannel_R, 
			enum.CryoTextureColorChannel_R, 
			enum.CryoTextureColorChannel_R,
			enum.CryoTextureColorChannel_One
	)
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)
	
	cryoLayer = cryoRecipe:addTextureLayer(nil, "brow_layer")
	cryoLayer:setBlending(enum.CryoBlendMode_LinearAlphaBlend)
	cryoLayer:setRecolorMode(enum.CryoRecolorMode_Tricolor)
	cryoLayer:setPrimaryColor(eyebrowcolor_pri)
	cryoLayer:setSecondaryColor(eyebrowcolor_sec)
	cryoLayer:setTertiaryColor(eyebrowcolor_ter)
	
	cryoLayer = cryoRecipe:addTextureLayer(nil, "brow_ambient_layer")
	cryoLayer:setTextureSwizzleMask(enum.CryoTextureColorChannel_R, enum.CryoTextureColorChannel_R, enum.CryoTextureColorChannel_R, enum.CryoTextureColorChannel_One)
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	if scalpmap then
		cryoLayer = cryoRecipe:addTextureLayer(nil, "scalp_layer")
		cryoLayer:setBlending(enum.CryoBlendMode_LinearAlphaBlend)
		cryoLayer:setRecolorMode(enum.CryoRecolorMode_Tricolor)
		cryoLayer:setPrimaryColor(haircolor_pri)
		cryoLayer:setSecondaryColor(haircolor_sec)
		cryoLayer:setTertiaryColor(haircolor_ter)
	elseif hairlinemap then
		cryoLayer = cryoRecipe:addTextureLayer(nil, "hairline_layer")
		cryoLayer:setBlending(enum.CryoBlendMode_LinearAlphaBlend)
		cryoLayer:setRecolorMode(enum.CryoRecolorMode_Tint)
		cryoLayer:setPrimaryColor(haircolor_sec)
		cryoLayer:setSecondaryColor(haircolor_sec)
		cryoLayer:setTertiaryColor(haircolor_sec)
	end

	local cryoCompositor = createCryoTextureCompositor(texture_uid, 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-----------------------------------------------------------------------------
local function _compositeSockCullMask(initData, desc, cullmap0, cullmap1, cullmap2 )
	local mips, compress, alpha = 0, true, 1.0

	local defaultHotspot = {0, 0, 1.0, 1.0}
	local rotation = 0

	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(cullmap0, "cullmap0")
	cryoResourceMap:addTexture(cullmap1, "cullmap1")
	cryoResourceMap:addTexture(cullmap2, "cullmap2")

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap0")
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap1")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap2")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	local cryoCompositor = createCryoTextureCompositor("SockCullMask", 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-------------------------------------------------------------------------------------
-- load functions

-----------------------------------------------------------------------------
-- load crest and hotspots

local function _loadCrestForWardrobe(initData, bgcolor)
	local teamid = initData.TeamId
	local crestid = initData.CrestAssetId

	-- calculate the background intensity and choose the appropriate crest
	local lum = 0.5
	if bgcolor then
		lum =_luminance(bgcolor)
	end

	local folder = lum < 0.5 and 'dark' or 'light'
	local crest_name = crestid < 1 and 
		string.format("data/ui/imgAssets/crest/%s/l%d.dds;data/ui/imgAssets/crest/dark/notfound.dds", folder, teamid) or
		string.format("data/ui/imgAssets/crest/custom/l%d.dds;data/ui/imgAssets/crest/ssf/l%d.dds;data/ui/imgAssets/crest/ssf/notfound.dds", 
			crestid, crestid)
	local ddsCrestMap = loadRuntimeDDS(crest_name)
	return ddsCrestMap
end


local function _loadTeamCrest(initData, prefix)
	-- if it's custom crest then we load it from GameModes chunk data
	local crestColorMap, crestCoeffMap, crestNormalMap

	local kit = initData.Kit
	local kit_type = initData.KitType
	local kit_year = initData.KitYear
	local is_generic_kit = initData.IsGeneric == 1

	local crest_coeff_name, crest_normal_name
	
	if initData.CrestAssetId < 1 and not is_generic_kit then 
		local crest_color_name  = string.format("%s_%d_%d_%d_color;crest_%d_%d_%d_color;crest_0_0_0_color", prefix, kit, kit_type, kit_year, kit, kit_type, kit_year)
		crestColorMap = loadAsync(brts.kit, crest_color_name, false, initData.laneId)

		crest_coeff_name  = string.format("%s_%d_%d_%d_coeff;crest_fallback_coeff", prefix, kit, kit_type, kit_year, prefix)
		crestCoeffMap  = loadAsync(brts.kit, crest_coeff_name, false, initData.laneId)

		crest_normal_name = string.format("%s_%d_%d_%d_normal;crest_fallback_normal", prefix, kit, kit_type, kit_year, prefix)
	else
		if is_generic_kit then
			crestColorMap = _loadCrestForWardrobe(initData, initData.KitColorJerseyPri)
		else
			local custom_crest_color_name = string.format(
			"data/ui/imgAssets/crest/custom/l%d.dds;data/ui/imgAssets/crest/ssf/l%d.dds;data/ui/imgAssets/crest/ssf/notfound.dds", 
			initData.CrestAssetId, initData.CrestAssetId)
			crestColorMap = loadRuntimeDDS(custom_crest_color_name)
		
		end
		

		crest_coeff_name  = "crest_fallback_coeff"
		crestCoeffMap  = loadAsync(brts.kit, crest_coeff_name, false, initData.laneId)

		crest_normal_name = "crest_fallback_normal"
	end

	
	if (SETTING.DecalsUseExtraMaps) then
		crestNormalMap = loadAsync(brts.kit, crest_normal_name, false, initData.laneId)
	end


	return crestColorMap, crestCoeffMap, crestNormalMap
end

local function _loadBrandMaps(initData, prefix, template_kit)
	
	local brandColorMap, brandCoeffMap, brandNormalMap
	
	local is_generic_kit = initData.IsGeneric == 1
	local kit = is_generic_kit and template_kit or initData.Kit
	local kit_type = is_generic_kit and 0 or initData.KitType
	local kit_year = is_generic_kit and 0 or initData.KitYear
	
	local brand_color_name = string.format("%s_%d_%d_%d_color;brand_fallback_color", prefix, kit, kit_type, kit_year)
	brandColorMap = loadAsync(brts.kit, brand_color_name, false, initData.laneId)
	
	local brand_coeff_name = string.format("%s_%d_%d_%d_coeff;brand_fallback_coeff", prefix,kit, kit_type, kit_year)
	brandCoeffMap  = loadAsync(brts.kit, brand_coeff_name, false, initData.laneId)
	
	if(SETTING.DecalsUseExtraMaps) then
		local brand_normal_name = string.format("%s_%d_%d_%d_normal;brand_fallback_normal", prefix, kit, kit_type, kit_year)
		brandNormalMap = loadAsync(brts.kit, brand_normal_name, false, initData.laneId)
	end
	
	return brandColorMap, brandCoeffMap, brandNormalMap
	
end

local function _loadMuscleFlexMaps(initData, prefix)
	local flexMask, flexNormalMap, flexAmbientMap
	if(SETTING.UseFlexMaps) then
		local gender = initData.Gender
		local flexmask_name    = prefix .. "_mask"
		local flexnormal_name  = string.format("%s_%d_normal", prefix, gender)
		local flexambient_name = string.format("%s_%d_ambient", prefix, gender)
		flexMask = loadAsync(brts.body, flexmask_name, false, initData.laneId)
		flexNormalMap = loadAsync(brts.body, flexnormal_name, false, initData.laneId)
		flexAmbientMap = loadAsync(brts.body, flexambient_name, false, initData.laneId)
	end
	return flexMask, flexNormalMap, flexAmbientMap
end

-----------------------------------------------------------------------------
local function loadKitShorts(items, initData, args, hotspotAsset, shorts_mesh)

	local is_mascot = initData.OfficialType == enum.OfficialType_Mascot
	
	-- dont load shorts if there is bottom outfit layer and it's not mascot
	if not is_mascot then
		local useWardrobe = initData.UseWardrobeBottom ~= 0 or initData.UseWardrobeBottomSecondLayer ~= 0
		if useWardrobe then return end
	end

	local allow_missing = false
	local is_generic_kit = initData.IsGeneric == 1
	local short_template_kit = GENERIC_KIT_TEMPLATE_ID + initData.ShortsTemplateIndex
	local kit = is_generic_kit and short_template_kit or initData.Kit
	local kit_type = is_generic_kit and 0 or initData.KitType
	local kit_year = is_generic_kit and 0 or initData.KitYear
	local gender = initData.Gender
	local dirt_type = initData.DirtType
	local short_style = initData.ShortStyle
	local is_cloth = initData.DisableCloth == 0 and "_cloth" or ""
	local load_player_shorts = not shorts_mesh and not is_mascot  -- not load player short for mascot
	
	-- todo: why do we have duplicated short assets without cloth suffix?
	-- shorts and gkpants
	if load_player_shorts then
		local shorts_name = string.format("shorts_0_%d_%d%s;shorts_0_%d_%d;shorts_0_0_%d", short_style, gender, is_cloth, short_style, gender, gender)
		shorts_mesh = loadAsync(brts.body, shorts_name, allow_missing, initData.laneId)
	end

	if not shorts_mesh then return end

	local color_name = string.format("shorts_%d_%d_%d_color;shorts_0_0_0_color", kit, kit_type, kit_year)
	local coeff_name = string.format("shorts_%d_%d_%d_coeff;shorts_0_0_0_coeff", kit, kit_type, kit_year)
	local ao_name = string.format("shorts_0_%d_%d_ambient", initData.Wet, gender)
	local normal_name = string.format("shorts_%d_%d_%d_normal;shorts_0_normal", kit, kit_type, kit_year)
	
	local wrinkle_normal = string.format("shorts_0_%d_normal_array", gender)
	if IS_MOBILE then
		wrinkle_normal = string.format("shorts_0_%d_normal_array_low", gender)		
	end
	
	
	local twist_mask = string.format("shorts_%d_twist_mask", gender)
	local bent_normal_name = string.format("shorts_0_%d_normal_bent", gender)

	local dirtmap_name = string.format("shorts_0_dk_%d", dirt_type)
	local dirtmask_name = string.format("shorts_%d_%d_dk_region", gender, dirt_type)

	local numberTens_name = string.format("numbers_%d_%d_color;numbers_0_%d_color", initData.ShortsNumberFont, initData.KitNumberTens, initData.KitNumberTens)
	local numberUnits_name = string.format("numbers_%d_%d_color;numbers_0_%d_color", initData.ShortsNumberFont, initData.KitNumberUnits, initData.KitNumberUnits)

	local taa_name = string.format("shorts_%d_%d_%d_taa;shorts_0_0_0_taa", kit, kit_type, kit_year)
	local weave_normal_array = string.format("weave_shorts_%d_%d_%d_normal_array;weave_shorts_0_0_0_normal_array", kit, kit_type, kit_year)
	local weave_coeff_array  = string.format("weave_shorts_%d_%d_%d_coeff_array;weave_shorts_0_0_0_coeff_array", kit, kit_type, kit_year)
	
	local is_goalie = short_style == 1
	if is_goalie then
		local gk_pants_kit = initData.GkPantsKit
		local gk_pants_type = initData.GkPantsKitType

		color_name = string.format("gkpants_%d_%d_0_color;gkpants_5200_2_0_color", gk_pants_kit, gk_pants_type)
		coeff_name = string.format("gkpants_%d_%d_0_coeff;gkpants_5200_2_0_coeff", gk_pants_kit, gk_pants_type)
		ao_name = "shorts_1_1_0_ambient"
		normal_name = string.format("gkpants_%d_%d_0_normal;gkpants_5200_2_0_normal", gk_pants_kit, gk_pants_type)
		bent_normal_name = string.format("gkpants_%d_normal_bent", gender)
		wrinkle_normal = string.format("gkpants_%d_%d_0_normal_array;gkpants_5200_2_0_normal_array", gk_pants_kit, gk_pants_type)
		
		taa_name = string.format("gkpants_%d_%d_0_taa;gkpants_5200_2_0_taa", gk_pants_kit, gk_pants_type)
		weave_normal_array = string.format("gkpants_%d_%d_0_weave_normal_array;gkpants_5200_2_0_weave_normal_array", gk_pants_kit, gk_pants_type)
		weave_coeff_array  = string.format("gkpants_%d_%d_0_weave_coeff_array;gkpants_5200_2_0_weave_coeff_array", gk_pants_kit, gk_pants_type)
	end
	
	local colorMap = loadAsync(brts.kit, color_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.kit, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(brts.kit, ao_name, false, initData.laneId)
	local normalMap
	if is_mascot then
		local bottom_id = initData.BottomSecondLayerId
		local bottom_variation = initData.BottomSecondLayerTextureVariation
		local bottom_class = initData.BottomSecondLayerClothingClass
		normal_name = string.format("bottom_%d_%d_%d_%d_normal;debug_texture_normal", bottom_id, bottom_class, bottom_variation, gender)
		normalMap = loadAsync(brts.wardrobe, normal_name, false, initData.laneId)
	else
		normalMap = loadAsync(brts.kit, normal_name, false, initData.laneId)
	end
	local bentNormalMap = SETTING.UseSpecularOcclusion and loadAsync(brts.kit, bent_normal_name, false, initData.laneId) or nil

	local wrinkleMap = loadAsync(brts.kit, wrinkle_normal, false, initData.laneId)
	local twistMap = loadAsync(brts.kit, twist_mask, false, initData.laneId)

	local dirtMap = loadAsync(brts.kit, dirtmap_name, false, initData.laneId)
	local dirtMask = loadAsync(brts.kit, dirtmask_name, false, initData.laneId)

	local numberTensMap = loadAsync(brts.kit, numberTens_name, false, initData.laneId)
	local numberUnitsMap = loadAsync(brts.kit, numberUnits_name, false, initData.laneId)

	-- crest
	local crestColorMap, crestCoeffMap, crestNormalMap = _loadTeamCrest(initData, "crest_shorts")
	
	-- brand
	local brandColorMap, brandCoeffMap, brandNormalMap = _loadBrandMaps(initData, "brand_shorts", short_template_kit)

	-- weave/anisotropic
	local taaMap = loadAsync(brts.kit, taa_name, false, initData.laneId)
	local weaveNormalMapArray = loadAsync(brts.kit, weave_normal_array, false, initData.laneId)
	local weaveCoeffMapArray = loadAsync(brts.kit, weave_coeff_array, false, initData.laneId)
	
	items[#items + 1] = futureCall(bindShorts, initData, args, shorts_mesh,
		colorMap, coeffMap, aoMap, 
		normalMap, bentNormalMap, wrinkleMap, 
		twistMap, dirtMap, dirtMask, 
		numberTensMap, numberUnitsMap, hotspotAsset,
		crestColorMap, crestNormalMap, crestCoeffMap, 
		brandColorMap, brandNormalMap, brandCoeffMap, 
		taaMap, weaveNormalMapArray, weaveCoeffMapArray)

	-- under shorts
	if initData.UnderShorts > -1 then
		local undershorts_name = string.format("undershorts_0_%d_%d_%d", initData.UnderShortStyle, initData.SockLength, gender)
		local undershorts_mesh = loadAsync(brts.body, undershorts_name, true, initData.laneId)
		-- common weave array for undergear
		weaveNormalMapArray = loadAsync(brts.kit, "weave_undergear_0_normal_array", false, initData.laneId)
		weaveCoeffMapArray = loadAsync(brts.kit, "weave_undergear_0_coeff_array", false, initData.laneId)
		
		items[#items + 1] = futureCall(bindUnderShorts, initData, args, undershorts_mesh, 
			colorMap, coeffMap, aoMap, 
			normalMap, bentNormalMap, wrinkleMap, 
			twistMap, dirtMap, dirtMask,
			taaMap, weaveNormalMapArray, weaveCoeffMapArray)
	end
end

-----------------------------------------------------------------------------
-- side: 0 - left, 1 - right, 2 - middle
local function loadBadge(id, initData, side)
	-- position: 0 - left, 1 - right, 2 - middle
	-- suffix: color, normal, coeff
	local makeBadgeName = function(id, kit, kit_type, kit_year, position, suffix)
		local pattern = "badge_%d_%d_%d_%d_%d_%s;badge_%d_%d_%d_%d_%d_%s;badge_%d_%d_%d_%d_%d_%s;badge_0_0_0_0_0_%s"
		return string.format(pattern, 
			id, kit, kit_type, kit_year, position, suffix,
			id, kit, kit_type, 0, position, suffix,
			id, 0, 0, 0, position, suffix, 
			suffix)
	end

	local kit = initData.Kit
	local kit_type = initData.KitType
	local kit_year = initData.KitYear

	local color_name = makeBadgeName(id, kit, kit_type, kit_year, side, "color")
	local normal_name = makeBadgeName(id, kit, kit_type, kit_year, side, "normal")
	local coeff_name = makeBadgeName(id, kit, kit_type, kit_year, side, "coeff")

	local colorMap = loadAsync(brts.badges, color_name, false, initData.laneId)
	local normalMap = loadAsync(brts.badges, normal_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.badges, coeff_name, false, initData.laneId)
	return {color = colorMap, normal = normalMap, coeff = coeffMap}
end

-----------------------------------------------------------------------------
local function loadArmband(competitionId, armbandId, armbandType, initData)
    -- as per DCL requirements, a CAPTAINARMBAND (teamkits table) value of -1, 0 or 100 means that we should ignore that value. If we get
    -- one of those three values, overwrite armbandId to -1 so that we don't find the asset to load and we fall back to 0_0_suffix.
    if armbandId == 0 or armbandId == -1 or armbandId == 100 then
        armbandId = -1
    end
    
	local makeName = function(competitionId, armbandId, armbandType, suffix) return string.format("armband_%d_%d_%s;armband_%d_0_%s;armband_%d_%d_%s;armband_0_0_%s", competitionId, armbandType, suffix, competitionId, suffix, armbandId, armbandType, suffix, suffix) end

	local color_name = makeName(competitionId, armbandId, armbandType, "color")
	local normal_name = makeName(competitionId, armbandId, armbandType, "normal")
	local coeff_name = makeName(competitionId, armbandId, armbandType, "coeff")

	local colorMap = loadAsync(brts.armband, color_name, false, initData.laneId)
	local normalMap = loadAsync(brts.armband, normal_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.armband, coeff_name, false, initData.laneId)
	return {color = colorMap, normal = normalMap, coeff = coeffMap}
end

-----------------------------------------------------------------------------
local function _isClothJersey(initData)
	return (initData.JerseyFit == 0 and initData.DisableCloth == 0)
end

local function loadKitJersey(items, generatedTextures, initData, args, hotspotAsset, competitionHotspot, assets, jersey_item, jersey_mesh)
	
	local is_mascot = initData.OfficialType == enum.OfficialType_Mascot
	
	-- don't load jersey if there is top base outfit and it's not mascot
	if not is_mascot then
		if initData.UseWardrobeTopBase ~= 0 then return end
	end

	local allow_missing = false
	local jersey_template_kit = GENERIC_KIT_TEMPLATE_ID + initData.JerseyTemplateIndex
	local is_generic_kit = initData.IsGeneric == 1
	local kit = is_generic_kit and jersey_template_kit or initData.Kit
	local kit_type = is_generic_kit and 0 or initData.KitType
	local kit_year = is_generic_kit and 0 or initData.KitYear
	local gender = initData.Gender
	local dirt_type = initData.DirtType
	local jersey_tucked = initData.JerseyTucked
	local jersey_fit = initData.JerseyFit
	local use_underarms = initData.UnderArms > -1 and not args.static_jersey
	local use_underneck = initData.UnderNeck > -1 and not args.static_jersey

	local is_cloth = _isClothJersey(initData) and "_cloth" or ""
	
	-- load mesh if not provided
	if not jersey_mesh then
		local jersey_name_fallback = string.format("jersey_0_0_0_0_0_0_%d_cloth", gender)
		local jersey_name = string.format("jersey_0_%d_%d_%d_%d_%d_%d%s;%s", initData.JerseyCollarType, initData.JerseySleeveLength, initData.IsCaptain,
			jersey_tucked, jersey_fit, gender, is_cloth, jersey_name_fallback)
		jersey_mesh = loadAsync(brts.body, jersey_name, allow_missing, initData.laneId)
	end

	if not jersey_mesh then return end

	-- textures
	local color_name = string.format("jersey_%d_%d_%d_color;jersey_0_0_0_color", kit, kit_type, kit_year)
	local coeff_name = string.format("jersey_%d_%d_%d_coeff;jersey_0_0_0_coeff", kit, kit_type, kit_year)
	local normal_name = string.format("jersey_%d_%d_%d_normal;jersey_0_normal", kit, kit_type, kit_year)
	local ao_name
	if SETTING.UsePackedAOMap then
		ao_name = string.format("jersey_%d_%d_ambient", jersey_tucked, gender)
	else
		ao_name = string.format("jersey_%d_%d_%d_ambient", jersey_tucked, initData.Wet, gender)
	end
	
	local wrinkle_normal = string.format("jersey_%d_%d_%d_normal_array", jersey_tucked, jersey_fit, gender)
	if IS_MOBILE then
		wrinkle_normal = string.format("jersey_%d_%d_%d_normal_array_low", jersey_tucked, jersey_fit, gender)
	end
	
	local twist_mask = string.format("jersey_%d_twist_mask", gender)
	local bent_normal_name = string.format("jersey_%d_%d_%d_normal_bent;jersey_0_normal", jersey_tucked, jersey_fit, gender)

	local dirtmap_name = string.format("jersey_dk_%d;jersey_dk_0", dirt_type)
	local dirtmask_name = string.format("jersey_%d_dk_region;jersey_0_dk_region", dirt_type)

	local numberTens_name = string.format("numbers_%d_%d_color;numbers_0_%d_color", initData.KitNumberFont, initData.KitNumberTens, initData.KitNumberTens)
	local numberUnits_name = string.format("numbers_%d_%d_color;numbers_0_%d_color", initData.KitNumberFont, initData.KitNumberUnits, initData.KitNumberUnits)
	
	local taa_name = string.format("jersey_%d_%d_%d_taa;jersey_0_0_0_taa", kit, kit_type, kit_year)
	local weave_normal_array = string.format("weave_jersey_%d_%d_%d_normal_array;weave_jersey_0_0_0_normal_array", kit, kit_type, kit_year)
	local weave_coeff_array = string.format("weave_jersey_%d_%d_%d_coeff_array;weave_jersey_0_0_0_coeff_array", kit, kit_type, kit_year)

	if args.static_jersey then wrinkle_normal = "jersey_0_normal_array" end

	local colorMap = loadAsync(brts.kit, color_name, false, initData.laneId)
	local aoMap = loadAsync(brts.kit, ao_name, false, initData.laneId)

	local coeffMap = loadAsync(brts.kit, coeff_name, false, initData.laneId)
	local normalMap
	if is_mascot then
		local top_id = initData.TopSecondLayerId
		local top_variation = initData.TopSecondLayerTextureVariation
		local top_class = initData.TopSecondLayerClothingClass
		normal_name = string.format("top_%d_%d_%d_%d_normal;debug_texture_normal", top_id, top_class, top_variation, gender)
		normalMap = loadAsync(brts.wardrobe, normal_name, false, initData.laneId)
	else
		normalMap = loadAsync(brts.kit, normal_name, false, initData.laneId)
	end

	local bentNormalMap = SETTING.UseSpecularOcclusion and loadAsync(brts.kit, bent_normal_name, false, initData.laneId) or nil

	local wrinkleMap = loadAsync(brts.kit, wrinkle_normal, false, initData.laneId)
	local twistMap = loadAsync(brts.kit, twist_mask, false, initData.laneId)

	local dirtMap = loadAsync(brts.kit, dirtmap_name, false, initData.laneId)
	local dirtMask = loadAsync(brts.kit, dirtmask_name, false, initData.laneId)

	local numberTensMap = loadAsync(brts.kit, numberTens_name, false, initData.laneId)
	local numberUnitsMap = loadAsync(brts.kit, numberUnits_name, false, initData.laneId)
	
	local numberTensFrontMap, numberUnitsFrontMap = nil, nil
	if SETTING.Generation >= 5 then 
		local numberTensFront_name = string.format("numbers_%d_%d_color;numbers_0_%d_color", initData.ShortsNumberFont, initData.KitNumberTens, initData.KitNumberTens)
		local numberUnitsFront_name = string.format("numbers_%d_%d_color;numbers_0_%d_color", initData.ShortsNumberFont, initData.KitNumberUnits, initData.KitNumberUnits)
		numberTensFrontMap = loadAsync(brts.kit, numberTensFront_name, false, initData.laneId)
		numberUnitsFrontMap = loadAsync(brts.kit, numberUnitsFront_name, false, initData.laneId)
	end

	local font_name = string.format("font_%d;font_0", initData.KitNameFont)
	local fontAsset = loadAsync(brts.font, font_name, false, initData.laneId)
	
	-- crest
	local crestColorMap, crestCoeffMap, crestNormalMap = _loadTeamCrest(initData, "crest") 
	
	-- brand
	local brandColorMap, brandCoeffMap, brandNormalMap = _loadBrandMaps(initData, "brand_jersey", jersey_template_kit)
	
	-- weave/anisotropic
	local taaMap = loadAsync(brts.kit, taa_name, false, initData.laneId)
	local weaveNormalMapArray = loadAsync(brts.kit, weave_normal_array, false, initData.laneId)
	local weaveCoeffMapArray = loadAsync(brts.kit, weave_coeff_array, false, initData.laneId)

	-- badges
	local badgeBakeMaskMap = loadAsync(brts.kit, "badge_bake_mask;badge_0_0_0_0_0_color", false, initData.laneId)
	local leftBadge = loadBadge(initData.JerseyBadgeLeftID, initData, 0)
	local rightBadge = loadBadge(initData.JerseyBadgeRightID, initData, 1)
	local middleBadge = loadBadge(initData.JerseyBadgeMiddleID, initData, 2)

	local competitionId = initData.TournamentId
	if initData.CompArmbandAllowed == 0 then
		competitionId = -1
	end

	local armbandBadge = loadArmband(competitionId, initData.JerseyArmbandID, initData.JerseyArmbandType, initData)

	-- color composite
	local colorGeneratedMap = futureCall(compositeJerseyWithBadges, initData, 
		hotspotAsset, competitionHotspot, BadgeColorCompositorDesc, false, badgeBakeMaskMap, 
		colorMap, leftBadge.color, rightBadge.color, middleBadge.color, armbandBadge.color)
	generatedTextures[#generatedTextures + 1] = colorGeneratedMap
	
	-- coeff composite
	local coeffGeneratedMap = futureCall(compositeJerseyWithBadges, initData, 
		hotspotAsset, competitionHotspot, BadgeCoeffCompositorDesc, false, badgeBakeMaskMap, 
		coeffMap, leftBadge.coeff, rightBadge.coeff, middleBadge.coeff, armbandBadge.coeff)
	generatedTextures[#generatedTextures + 1] = coeffGeneratedMap
	
	-- normal composite
	local normalGeneratedMap = futureCall(compositeJerseyWithBadges, initData, 
		hotspotAsset, competitionHotspot, BadgeNormalCompositorDesc, true, badgeBakeMaskMap, 
		normalMap, leftBadge.normal, rightBadge.normal, middleBadge.normal, armbandBadge.normal)
	generatedTextures[#generatedTextures + 1] = normalGeneratedMap

	-- player name
	local playerNameGeneratedMap = futureCall(compositePlayerName, initData, fontAsset)
	generatedTextures[#generatedTextures + 1] = playerNameGeneratedMap

	-- cloth mask composite
	if not args.static_jersey and SETTING.GenerateRigidClothMask then
		local maskWhite = loadAsync(brts.base, "clothmask_white_square_8x8", false, initData.laneId)
		local clothMaskGeneratedMap = futureCall(compositeClothRigidMask, initData, hotspotAsset, competitionHotspot, ClothMaskCompositorDesc, maskWhite)
		generatedTextures[#generatedTextures + 1] = clothMaskGeneratedMap
	
		assets.RigidTextureMaskJerseyGenerated = clothMaskGeneratedMap
	end

	-- jersey material
	local item = futureCall(bindJersey, initData, args, jersey_item, jersey_mesh, 
		colorMap, coeffMap, aoMap, 
		normalMap, bentNormalMap, wrinkleMap, 
		twistMap, dirtMap, dirtMask, 
		numberTensMap, numberUnitsMap, numberTensFrontMap, numberUnitsFrontMap, hotspotAsset,
		colorGeneratedMap, normalGeneratedMap, coeffGeneratedMap, playerNameGeneratedMap,
		crestColorMap, crestNormalMap, crestCoeffMap, 
		brandColorMap, brandNormalMap, brandCoeffMap, 
		taaMap, weaveNormalMapArray, weaveCoeffMapArray)

	-- If jersey_item was provided then it should already exist in 'items' so don't add it.
	if not jersey_item then
		items[#items + 1] = item
	end


	-- under arms
	if (use_underarms) then
		local underarms_name = string.format("underarms_0_0_%d", gender)
		local underarms_mesh = loadAsync(brts.body, underarms_name, false, initData.laneId)
		-- common weave array for undergear
		weaveNormalMapArray = loadAsync(brts.kit, "weave_undergear_0_normal_array", false, initData.laneId)
		weaveCoeffMapArray = loadAsync(brts.kit, "weave_undergear_0_coeff_array", false, initData.laneId)
	
		items[#items + 1] = futureCall(bindUnderArms, initData, underarms_mesh,
			colorMap, coeffMap, aoMap, 
			normalMap, bentNormalMap, wrinkleMap, 
			twistMap, dirtMap, dirtMask, 
			taaMap, weaveNormalMapArray, weaveCoeffMapArray)
	end

	-- under neck
	if (use_underneck) then
		local underneck_name = string.format("underneck_0_0_%d", gender)
		local underneck_mesh = loadAsync(brts.body, underneck_name, false, initData.laneId)
		-- common weave array for undergear
		weaveNormalMapArray = loadAsync(brts.kit, "weave_undergear_0_normal_array", false, initData.laneId)
		weaveCoeffMapArray = loadAsync(brts.kit, "weave_undergear_0_coeff_array", false, initData.laneId)
		
		items[#items + 1] = futureCall(bindUnderNeck, initData, underneck_mesh,
			colorMap, coeffMap, aoMap, 
			normalMap, bentNormalMap, wrinkleMap, 
			twistMap, dirtMap, dirtMask,
			taaMap, weaveNormalMapArray, weaveCoeffMapArray)
	end

end

-----------------------------------------------------------------------------
local function loadShoes(items, initData)
	if initData.UseShoe == 0 then return end
	
	local allow_missing = false
	local shoe_type = initData.ShoeType
	local shoe_design = initData.ShoeDesign
	local is_cloth = (initData.DisableCloth == 0 and SETTING.EnableShoeLacesCloth) and "_cloth" or ""

	local shoe_name = string.format("shoe_%d%s;shoe_%d;shoe_15;shoe_0", shoe_type, is_cloth, shoe_type)
	local shoe_mesh = loadAsync(brts.shoes, shoe_name, allow_missing, initData.laneId)
	if not shoe_mesh then return end

	local color_name = string.format("shoe_%d_%d_color;shoe_15_0_color;debug_texture_color", shoe_type, shoe_design)
	local normal_name = string.format("shoe_%d_%d_normal;shoe_15_0_normal;debug_texture_normal", shoe_type, shoe_design)
	local coeff_name = string.format("shoe_%d_%d_coeff;shoe_15_0_coeff;debug_texture_coeff", shoe_type, shoe_design)
	local ambient_name = string.format("shoe_%d_%d_ambient;shoe_15_0_ambient;debug_texture_aoblend", shoe_type, shoe_design)

	local dirtmap_name = string.format("shoe_dk_%d;debug_texture_dk", initData.DirtType)
	local dirtmask_name = "shoes_dk_region;debug_texture_mask"

	local colorMap = loadAsync(brts.shoes, color_name, false, initData.laneId)
	local normalMap = loadAsync(brts.shoes, normal_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.shoes, coeff_name, false, initData.laneId)
	local ambientMap = loadAsync(brts.shoes, ambient_name, false, initData.laneId)
	

	local dirtMap = loadAsync(brts.kit, dirtmap_name, false, initData.laneId)
	local dirtMask = loadAsync(brts.kit, dirtmask_name, false, initData.laneId)

	items[#items + 1] = futureCall(bindShoe, initData, shoe_mesh, 
		colorMap, coeffMap, normalMap, ambientMap, dirtMap, dirtMask)
end

-----------------------------------------------------------------------------
local function loadSocks(items, generatedTextures, initData, args, hotspotAsset, assets)
	local sock_length = initData.SockLength
	local sock_style = initData.SockStyle

	if sock_length == 9999 or sock_length == -1 then return end
	local is_gkpants = initData.ShortStyle == 1 
	if(is_gkpants) then return end	

	local allow_missing = true

	local is_generic_kit = initData.IsGeneric == 1
	local socks_template_kit = GENERIC_KIT_TEMPLATE_ID + initData.SocksTemplateIndex
	local kit = is_generic_kit and socks_template_kit or initData.Kit
	local kit_type = is_generic_kit and 0 or initData.KitType
	local kit_year = is_generic_kit and 0 or initData.KitYear
	local gender = initData.Gender

	-- lua always initializes variable to nil
	local socks_name
	local color_name, normal_name, coeff_name, ao_name, wrinkle_normal
	local taa_name, weave_normal_array, weave_coeff_array
	local mesh_brt, texture_brt
	local is_mascot = initData.OfficialType == enum.OfficialType_Mascot

	if initData.UseKitSock ~= 0 or is_mascot then
		mesh_brt, texture_brt = brts.body, brts.kit
		if is_mascot then
			mesh_brt = brts.wardrobe
			socks_name = string.format("sock_%d_%d_%d;sock_0_0_%d", sock_length, initData.SockClothingClass, gender, gender)
		else
			socks_name = string.format("sock_0_%d_%d_%d_0;sock_0_0_1_%d_0", sock_length, sock_style, gender, gender)
		end

		color_name = string.format("socks_%d_%d_%d_color;socks_0_0_0_color", kit, kit_type, kit_year)
		normal_name = string.format("socks_%d_%d_%d_normal;socks_0_normal", kit, kit_type, kit_year)
		wrinkle_normal = string.format("socks_%d_%d_%d_normal_array;socks_0_1_%d_normal_array", sock_length, sock_style, gender, gender)
		bent_normal_name = string.format("socks_%d_0_normal_bent", gender)
		coeff_name = string.format("socks_%d_%d_%d_coeff;socks_0_0_0_coeff", kit, kit_type, kit_year)
		ao_name = string.format("socks_0_%d_%d_ambient", initData.Wet, gender)
		taa_name = string.format("socks_%d_%d_%d_taa;socks_0_0_0_taa", kit, kit_type, kit_year)
		weave_normal_array = string.format("weave_socks_%d_%d_%d_normal_array;weave_socks_0_0_0_normal_array", kit, kit_type, kit_year)
		weave_coeff_array = string.format("weave_socks_%d_%d_%d_coeff_array;weave_socks_0_0_0_coeff_array", kit, kit_type, kit_year)	
	elseif initData.UseWardrobeSock ~= 0 then
		mesh_brt, texture_brt = brts.wardrobe, brts.wardrobe

		local sock_class = initData.SockClothingClass
		local sock_variation = initData.SockVariation
		socks_name = string.format("sock_%d_%d_%d", sock_length, sock_class, gender)
		color_name = string.format("sock_%d_%d_%d_%d_color;debug_texture_color", sock_length, sock_class, sock_variation, gender)
		normal_name = string.format("sock_%d_%d_%d_%d_normal;debug_texture_normal", sock_length, sock_class, sock_variation, gender)
		wrinkle_normal = string.format("sock_%d_%d_%d_%d_normal;debug_texture_normal", sock_length, sock_class, sock_variation, gender)
		bent_normal_name = "socks_0_normal"
		coeff_name = string.format("sock_%d_%d_%d_%d_coeff;debug_texture_coeff", sock_length, sock_class, sock_variation, gender)
		ao_name = string.format("sock_%d_%d_ambient;debug_texture_aoblend", sock_length, gender)
		taa_name = "socks_0_0_0_taa"
		local clothingclass = 1
		weave_normal_array = string.format("sock_%d_%d_weave_nm_array;sock_11_1_weave_nm_array", sock_length, clothingclass)
		weave_coeff_array = string.format("sock_%d_%d_weave_coeff_array;sock_11_1_weave_coeff_array", sock_length, clothingclass)
	end

	if args.static_socks then
		socks_name = string.format("static_socks_%d", initData.StaticSocksVariation)
		mesh_brt = brts.worlds_clothing
	end

	-- no socks
	if not socks_name then return end

	-- no socks
	local socks_mesh = loadAsync(mesh_brt, socks_name, allow_missing, initData.laneId)
	if not socks_mesh then return end

	-- composite cullmask
	local bottom0_cullmask_name = string.format("bottom_%d_%d_sockcull", initData.BottomId, gender)
	local bottom1_cullmask_name = string.format("bottom_%d_%d_sockcull", initData.BottomSecondLayerId, gender)
	local shoe_cullmask_name = string.format("shoe_%d_0_sockcull", initData.ShoeType)

	local nocullMap = loadAsync(brts.body, "nocull", false, initData.laneId)
	local bottom0_cullMap = loadAsync(brts.wardrobe, bottom0_cullmask_name, allow_missing, initData.laneId) or nocullMap
	local bottom1_cullMap = loadAsync(brts.wardrobe, bottom1_cullmask_name, allow_missing, initData.laneId) or nocullMap
	local shoe_cullMap = loadAsync(brts.shoes, shoe_cullmask_name, allow_missing, initData.laneId) or nocullMap

	local generatedCullMap = futureCall(_compositeSockCullMask, initData, CullMaskCompositorDesc, bottom0_cullMap, bottom1_cullMap, shoe_cullMap)
	generatedTextures[#generatedTextures + 1] = generatedCullMap

	assets.CullTextureMaskSocksGenerated = generatedCullMap

	-- textures
	local twist_mask = "socks_0_twist_mask"

	local dirtmap_name = string.format("socks_dk_%d", initData.DirtType)
	local dirtmask_name = "socks_0_0_dk_region"

	local colorMap = loadAsync(texture_brt, color_name, false, initData.laneId)
	local coeffMap = loadAsync(texture_brt, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(texture_brt, ao_name, false, initData.laneId)
	local normalMap = loadAsync(texture_brt, normal_name, false, initData.laneId)
	local bentNormalMap = SETTING.UseSpecularOcclusion and loadAsync(brts.kit, bent_normal_name, false, initData.laneId) or nil

	local wrinkleMap = loadAsync(texture_brt, wrinkle_normal, false, initData.laneId)
	
	local twistMap = loadAsync(brts.kit, twist_mask, false, initData.laneId)

	local dirtMap = loadAsync(brts.kit, dirtmap_name, false, initData.laneId)
	local dirtMask = loadAsync(brts.kit, dirtmask_name, false, initData.laneId)
	
	local taaMap = loadAsync(brts.kit, taa_name, false, initData.laneId)
	local weaveNormalMapArray = loadAsync(texture_brt, weave_normal_array, false, initData.laneId)
	local weaveCoeffMapArray = loadAsync(texture_brt, weave_coeff_array, false, initData.laneId)

	items[#items + 1] = futureCall(bindSocks, initData, args, socks_mesh, hotspotAsset,
		colorMap, coeffMap, aoMap, 
		normalMap, bentNormalMap, wrinkleMap, 
		twistMap, dirtMap, dirtMask, taaMap, 
		weaveNormalMapArray, weaveCoeffMapArray,
		generatedCullMap)
end

-----------------------------------------------------------------------------
local function loadGkGloves(items, initData)
	if (initData.IsGoalie == 0 and initData.UseKitGkGloves == 0) 
		or initData.GkGloveType==-1 then return end

	local glove_type = initData.GkGloveType

	local mesh_name = string.format("gkglove_%d;gkglove_1", glove_type)
	local mesh = loadAsync(brts.accessory, mesh_name, false, initData.laneId)

	local color_name = string.format("gkglove_%d_color;gkglove_1_color;debug_texture_color", glove_type)
	local normal_name = string.format("gkglove_%d_normal;gkglove_1_normal;debug_texture_normal", glove_type)
	local coeff_name = string.format("gkglove_%d_coeff;gkglove_1_coeff;debug_texture_coeff", glove_type)

	local colorMap = loadAsync(brts.accessory, color_name, false, initData.laneId)
	local normalMap = loadAsync(brts.accessory, normal_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.accessory, coeff_name, false, initData.laneId)

	--[[
	local color_name = string.format("gkglove_%d_color", glove_type)
	local normal_name = string.format("gkglove_%d_normal", glove_type)
	local coeff_name = string.format("gkglove_%d_coeff", glove_type)

	local colorMap = loadAsync(brts.accessory, color_name, true, initData.laneId) or loadAsync(brts.base, "debug_texture_color", false, initData.laneId)
	local normalMap = loadAsync(brts.accessory, normal_name, true, initData.laneId) or loadAsync(brts.base, "debug_texture_normal", false, initData.laneId)
	local coeffMap = loadAsync(brts.accessory, coeff_name, true, initData.laneId) or loadAsync(brts.base, "debug_texture_coeff", false, initData.laneId)
	]]--

	-- not used
	--local dirtMap = loadAsync(brts.kit, "gkglove_dk", false, initData.laneId)
	--local dirtMask = loadAsync(brts.kit, dirtmask_name, false, initData.laneId)

	items[#items + 1] = futureCall(bindGkGloves, initData, mesh, colorMap, coeffMap, normalMap)
end
-----------------------------------------------------------------------------
local function loadHotspots(initData)
	local hotspots_name = string.format("hotspots_%d_%d_%d;hotspots_0_0_0", initData.Kit, initData.KitType, initData.KitYear)
	local hotspotAsset = loadAsync(brts.hotspots, hotspots_name, false, initData.laneId)

	local competitionHotspot = loadAsync(brts.hotspots, "competition_hotspots", false, initData.laneId)
	return hotspotAsset, competitionHotspot
end
-----------------------------------------------------------------------------
-- load outfit
local function loadBottom0(items, initData)
	if initData.UseWardrobeBottom == 0 then return end

	local allow_missing = true

	local gender = initData.Gender
	local bottom_id = initData.BottomId
	local bottomgeo_id = initData.BottomGeoId
	local bottom_class = initData.BottomClothingClass
	local bottom_variation = initData.BottomTextureVariation
	
	local bottom0_name = string.format("bottom_0_%d_%d_0_0_%d", bottomgeo_id, bottom_class, gender)
	local bottom0_mesh = loadAsync(brts.wardrobe, bottom0_name, allow_missing, initData.laneId)

	local color_name = string.format("bottom_%d_%d_%d_%d_color;debug_texture_color", bottom_id, bottom_class, bottom_variation, gender)
	local normal_name = string.format("bottom_%d_%d_%d_%d_normal;debug_texture_normal", bottom_id, bottom_class, bottom_variation, gender)
	local coeff_name = string.format("bottom_%d_%d_%d_%d_coeff;debug_texture_coeff",bottom_id, bottom_class, bottom_variation, gender)
	local ao_name = string.format("bottom_%d_%d_%d_%d_ambient;bottom_%d_%d_ambient;wardrobe_fallback_ambient", bottom_id, bottom_class, bottom_variation, gender, bottom_id, gender)
	local taa_name = string.format("bottom_%d_%d_%d_%d_taa;bottom_%d_%d_taa;wardrobe_fallback_taa", bottom_id, bottom_class, bottom_variation, gender, bottom_id, gender)

	local weave_normal_name = string.format("bottom_%d_%d_weave_nm_array;debug_texture_normal_array", bottom_id, bottom_class)
	local weave_coeff_name = string.format("bottom_%d_%d_weave_coeff_array;debug_texture_normal_array", bottom_id, bottom_class)

	local cull_name = string.format("bottom_%d_%d_clothingcull", initData.BottomSecondLayerGeoId, gender)

	local colorMap = loadAsync(brts.wardrobe, color_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.wardrobe, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(brts.wardrobe, ao_name, false, initData.laneId)
	local normalMap = loadAsync(brts.wardrobe, normal_name, false, initData.laneId)
	local taaMap = SETTING.UseAnisoSpecular and loadAsync(brts.wardrobe, taa_name, false, initData.laneId) or nil

	local weaveNormalMap = loadAsync(brts.wardrobe, weave_normal_name, false, initData.laneId)
	local weaveCoeffMap = loadAsync(brts.wardrobe, weave_coeff_name, false, initData.laneId)
	
	local cullMap = loadAsync(brts.wardrobe, cull_name, allow_missing, initData.laneId)
	if not cullMap then cullMap = loadAsync(brts.body, "nocull", false, initData.laneId) end

	local hotspots_name = string.format("bottom_%d_%d_%d_%d_hotspot;wardrobe_fallback_hotspot", bottom_id, bottom_class, bottom_variation, gender)
	local hotspot = loadAsync(brts.wardrobe, hotspots_name, allow_missing, initData.laneId)

	if bottom0_mesh then
		items[#items + 1] = futureCall(bindBottom0, initData, bottom0_mesh,
			colorMap, coeffMap, aoMap, normalMap, taaMap,
			weaveCoeffMap, weaveNormalMap, cullMap, hotspot)
	end
end

-----------------------------------------------------------------------------
local function loadBottom1(items, initData)
	if initData.UseWardrobeBottomSecondLayer == 0 then return end

	local allow_missing = true

	local gender = initData.Gender
	local bottom_id = initData.BottomSecondLayerId
	local bottomgeo_id = initData.BottomSecondLayerGeoId
	local bottom_class = initData.BottomSecondLayerClothingClass
	local bottom_variation = initData.BottomSecondLayerTextureVariation

	local bottom1_name = string.format("bottom_0_%d_%d_0_0_%d", bottomgeo_id, bottom_class, gender)
	local bottom1_mesh = loadAsync(brts.wardrobe, bottom1_name, allow_missing, initData.laneId)
	local is_mascot = initData.OfficialType == enum.OfficialType_Mascot
	if is_mascot then
	
		--runtime overrides 
		local args = {
			use_warpcloth = false,
			static_shorts = true,
			mascot = true
		}

		-- variables
		local generatedTextures = {}
		local assets = {}

		-- hotspots
		local hotspotAsset, competitionHotspot = loadHotspots(initData)

		-- load kit 
		loadKitShorts(items, initData, args, hotspotAsset, bottom1_mesh)
		return
	end

	local color_name = string.format("bottom_%d_%d_%d_%d_color;debug_texture_color", bottom_id, bottom_class, bottom_variation, gender)
	local normal_name = string.format("bottom_%d_%d_%d_%d_normal;debug_texture_normal", bottom_id, bottom_class, bottom_variation, gender)
	local coeff_name = string.format("bottom_%d_%d_%d_%d_coeff;debug_texture_coeff", bottom_id, bottom_class, bottom_variation, gender)
	local ao_name = string.format("bottom_%d_%d_%d_%d_ambient;bottom_%d_%d_ambient;wardrobe_fallback_ambient", bottom_id, bottom_class, bottom_variation, gender, bottom_id, gender)
	local taa_name = string.format("bottom_%d_%d_%d_%d_taa;bottom_%d_%d_taa;wardrobe_fallback_taa", bottom_id, bottom_class, bottom_variation, gender, bottom_id, gender)

	local weave_normal_name = string.format("bottom_%d_%d_weave_nm_array;debug_texture_normal_array", bottom_id, bottom_class)
	local weave_coeff_name = string.format("bottom_%d_%d_weave_coeff_array;debug_texture_normal_array", bottom_id, bottom_class)

	local colorMap = loadAsync(brts.wardrobe, color_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.wardrobe, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(brts.wardrobe, ao_name, false, initData.laneId)
	local normalMap = loadAsync(brts.wardrobe, normal_name, false, initData.laneId)
	local taaMap = SETTING.UseAnisoSpecular and loadAsync(brts.wardrobe, taa_name, false, initData.laneId) or nil
	
	local weaveNormalMap = loadAsync(brts.wardrobe, weave_normal_name, false, initData.laneId)
	local weaveCoeffMap = loadAsync(brts.wardrobe, weave_coeff_name, false, initData.laneId)
	
	local cullMap = loadAsync(brts.body, "nocull", false, initData.laneId)

	local hotspots_name = string.format("bottom_%d_%d_%d_%d_hotspot;wardrobe_fallback_hotspot", bottom_id, bottom_class, bottom_variation, gender)
	local hotspot = loadAsync(brts.wardrobe, hotspots_name, allow_missing, initData.laneId)

	-- loading different crest from UI folder, test: mload 0 2
	local black = {0.05, 0.05, 0.05, 0}
	local ddsCrestMap = _loadCrestForWardrobe(initData, black)

	if bottom1_mesh then
		items[#items + 1] = futureCall(bindBottom1, initData, bottom1_mesh,
			colorMap, coeffMap, aoMap, normalMap, taaMap,
			weaveCoeffMap, weaveNormalMap, cullMap, hotspot, ddsCrestMap)
	end
end

-----------------------------------------------------------------------------
local function loadTop0(items, initData)
	if initData.UseWardrobeTopBase == 0 then return end

	local allow_missing = true
	
	local gender = initData.Gender
	local top_id = initData.TopBaseId
	local topgeo_id = initData.TopBaseGeoId
	local top_class = initData.TopBaseClothingClass
	local top_variation = initData.TopBaseTextureVariation

	local top0_name = string.format("top_0_%d_%d_0_0_%d", topgeo_id, top_class, gender)
	local top0_mesh = loadAsync(brts.wardrobe, top0_name, allow_missing, initData.laneId)

	local color_name = string.format("top_%d_%d_%d_%d_color;debug_texture_color", top_id, top_class, top_variation, gender)
	local normal_name = string.format("top_%d_%d_%d_%d_normal;debug_texture_normal", top_id, top_class, top_variation, gender)
	local coeff_name = string.format("top_%d_%d_%d_%d_coeff;debug_texture_coeff", top_id, top_class, top_variation, gender)
	local ao_name = string.format("top_%d_%d_%d_%d_ambient;top_%d_%d_ambient;wardrobe_fallback_ambient", top_id, top_class, top_variation, gender, top_id, gender)
	local taa_name = string.format("top_%d_%d_%d_%d_taa;top_%d_%d_taa;wardrobe_fallback_taa", top_id, top_class, top_variation, gender, top_id, gender)
	
	local weave_normal_name = string.format("top_%d_%d_weave_nm_array;debug_texture_normal_array", top_id, top_class)
	local weave_coeff_name = string.format("top_%d_%d_weave_coeff_array;debug_texture_normal_array", top_id, top_class)

	local cull_name = string.format("top_%d_%d_clothingcull", initData.TopSecondLayerGeoId, gender)

	local colorMap = loadAsync(brts.wardrobe, color_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.wardrobe, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(brts.wardrobe, ao_name, false, initData.laneId)
	local normalMap = loadAsync(brts.wardrobe, normal_name, false, initData.laneId)
	local taaMap = SETTING.UseAnisoSpecular and loadAsync(brts.wardrobe, taa_name, false, initData.laneId) or nil

	local weaveNormalMap = loadAsync(brts.wardrobe, weave_normal_name, false, initData.laneId)
	local weaveCoeffMap = loadAsync(brts.wardrobe, weave_coeff_name, false, initData.laneId)
	
	local cullMap = loadAsync(brts.wardrobe, cull_name, allow_missing, initData.laneId)
	if not cullMap then cullMap = loadAsync(brts.body, "nocull", false, initData.laneId) end
	
	local hotspots_name = string.format("top_%d_%d_%d_%d_hotspot;wardrobe_fallback_hotspot", top_id, top_class, top_variation, gender)
	local hotspot = loadAsync(brts.wardrobe, hotspots_name, allow_missing, initData.laneId)

	if top0_mesh then
		items[#items + 1] = futureCall(bindTop0, initData, top0_mesh,
			colorMap, coeffMap, aoMap, normalMap, taaMap,
			weaveCoeffMap, weaveNormalMap, cullMap, hotspot)
	end
end

-----------------------------------------------------------------------------
local function loadTop1(items, initData)
	if initData.UseWardrobeTopSecondLayer == 0 then return end

	local allow_missing = true

	local gender = initData.Gender
	local top_id = initData.TopSecondLayerId
	local topgeo_id = initData.TopSecondLayerGeoId
	local top_class = initData.TopSecondLayerClothingClass
	local top_variation = initData.TopSecondLayerTextureVariation
	local is_mascot = initData.OfficialType == enum.OfficialType_Mascot
	local top1_name = string.format("top_0_%d_%d_0_0_%d", topgeo_id, top_class, gender)
	local top1_mesh = loadAsync(brts.wardrobe, top1_name, allow_missing, initData.laneId)
	
	if is_mascot then
		--runtime overrides 
		local args = {
			use_warpcloth = false,
			static_jersey = true,
			mascot = true
		}

		-- variables
		local generatedTextures = {}
		local assets = {}

		-- hotspots
		local hotspotAsset, competitionHotspot = loadHotspots(initData)

		-- load kit 
		loadKitJersey(items, generatedTextures, initData, args, hotspotAsset, competitionHotspot, assets, nil, top1_mesh)
		return
	end

	local color_name = string.format("top_%d_%d_%d_%d_color;debug_texture_color", top_id, top_class, top_variation, gender)
	local normal_name = string.format("top_%d_%d_%d_%d_normal;debug_texture_normal", top_id, top_class, top_variation, gender)
	local coeff_name = string.format("top_%d_%d_%d_%d_coeff;debug_texture_coeff", top_id, top_class, top_variation, gender)
	local ao_name = string.format("top_%d_%d_%d_%d_ambient;top_%d_%d_ambient;wardrobe_fallback_ambient", top_id, top_class, top_variation, gender, top_id, gender)
	local taa_name = string.format("top_%d_%d_%d_%d_taa;top_%d_%d_taa;wardrobe_fallback_taa", top_id, top_class, top_variation, gender, top_id, gender)

	local weave_normal_name = string.format("top_%d_%d_weave_nm_array;debug_texture_normal_array", top_id, top_class)
	local weave_coeff_name = string.format("top_%d_%d_weave_coeff_array;debug_texture_normal_array", top_id, top_class)

	local colorMap = loadAsync(brts.wardrobe, color_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.wardrobe, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(brts.wardrobe, ao_name, false, initData.laneId)
	local normalMap = loadAsync(brts.wardrobe, normal_name, false, initData.laneId)
	local taaMap = SETTING.UseAnisoSpecular and loadAsync(brts.wardrobe, taa_name, false, initData.laneId) or nil

	local weaveNormalMap = loadAsync(brts.wardrobe, weave_normal_name, false, initData.laneId)
	local weaveCoeffMap = loadAsync(brts.wardrobe, weave_coeff_name, false, initData.laneId)
	
	local cullMap = loadAsync(brts.body, "nocull", false, initData.laneId)

	local hotspots_name = string.format("top_%d_%d_%d_%d_hotspot;wardrobe_fallback_hotspot", top_id, top_class, top_variation, gender)
	local hotspot = loadAsync(brts.wardrobe, hotspots_name, allow_missing, initData.laneId)
	
	-- loading different crest from UI folder, test: mload 0 2
	local black = {0.05, 0.05, 0.05, 0}
	local ddsCrestMap = _loadCrestForWardrobe(initData, black)

	if top1_mesh then
		items[#items + 1] = futureCall(bindTop1, initData, top1_mesh,
			colorMap, coeffMap, aoMap, normalMap, taaMap,
			weaveCoeffMap, weaveNormalMap, cullMap, hotspot, ddsCrestMap)
	end
end

-----------------------------------------------------------------------------
local function _loadTattoo(tattooid, initData)
	local allow_missing = false
	local tattoo_map = loadAsync(brts.tattoo, string.format("tattoo_%d_color;tattoo_0_color", tattooid), allow_missing, initData.laneId)
	local hotspot_file = loadAsync(brts.tattoo, string.format("tattoo_%d_hotspot;tattoo_0_hotspot", tattooid), allow_missing, initData.laneId)
	return tattoo_map, hotspot_file
end

-----------------------------------------------------------------------------
local function bindUpperBody(initData, args, slot, mesh, colorMap, 
							coeffMap, normalMap, bentNormalMap,
							dirtMap, dirtMask, sssMap, 
							cullMapGenerated, skinMapGenerated, 
							flexMask, flexNormalMap, flexAmbientMap, 
							exertionNormalMap, exertionCoeffMap)
	local is_kit_body = (slot == slots.arms or slot == slots.arms_short)
		
	local item = createItem("bodyupper_item", slot, initData.laneId)

	if is_kit_body then
		if (slot == slots.arms) then 
			item:setIncludeCullTagHashes("Arms")
			item:setExcludeCullTagHashes("ArmsShort") 
		end
		if (slot == slots.arms_short) then
			item:setIncludeCullTagHashes("ArmsShort")
		end
	end
	_addPsdTags(initData, args, item, "psd_arms")

	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)

	local material = item:addMaterial("body_mat")

	-- textures
	if skinMapGenerated then 

		material:addGenTexture(ShaderParam.colorTexture, skinMapGenerated)
	else

		material:addTexture(ShaderParam.colorTexture, colorMap)
	end


	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.sssTexture, sssMap)

	_addMuscleFlexParams(material, flexMask, flexNormalMap, flexAmbientMap)
	
	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end
	if exertionNormalMap then	

		material:addTexture(ShaderParam.exertionNormalTexture, exertionNormalMap)

		material:addTexture(ShaderParam.exertionCoeffTexture, exertionCoeffMap)
	end

	-- runtime generated textures

	material:addGenTexture(ShaderParam.cullTexture, cullMapGenerated)

	_addDirtShaderParams(material, initData, dirtMap, dirtMask)


	material:addVector(ShaderParam.muscularity, { initData.Muscularity, 0,0,0 })

	return item
end

-----------------------------------------------------------------------------
local function bindLowerBody(initData, args, slot, mesh, colorMap, 
							coeffMap, normalMap, bentNormalMap,
							dirtMap, dirtMask, sssMap,
							cullMapGenerated, skinMapGenerated,
							flexMask, flexNormalMap, flexAmbientMap, 
							exertionNormalMap, exertionCoeffMap)
	local is_kit_body = (slot == slots.legs)
		
	local item = createItem("bodylower_item", slot, initData.laneId)

	if is_kit_body then
		item:setIncludeCullTagHashes("Legs")
	end
	_addPsdTags(initData, args, item, "psd_legs")

	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder)
	
	local material = item:addMaterial("body_mat")

	-- textures
	if skinMapGenerated then 

		material:addGenTexture(ShaderParam.colorTexture, skinMapGenerated)
	else

		material:addTexture(ShaderParam.colorTexture, colorMap)
	end


	material:addTexture(ShaderParam.coefficientTexture, coeffMap)

	material:addTexture(ShaderParam.normalTexture, normalMap)

	material:addTexture(ShaderParam.sssTexture, sssMap)

	if bentNormalMap then

		material:addTexture(ShaderParam.bentNormalTexture, bentNormalMap)
	end
	if exertionNormalMap then

		material:addTexture(ShaderParam.exertionNormalTexture, exertionNormalMap)

		material:addTexture(ShaderParam.exertionCoeffTexture, exertionCoeffMap)
	end
	
	_addMuscleFlexParams(material, flexMask, flexNormalMap, flexAmbientMap)
	
	-- runtime generated textures

	material:addGenTexture(ShaderParam.cullTexture, cullMapGenerated)
	

	_addDirtShaderParams(material, initData, dirtMap, dirtMask)


	material:addVector(ShaderParam.muscularity, { initData.Muscularity, 0,0,0 })

	return item
end

-----------------------------------------------------------------------------
local function _compositeBodyUpperTattoo(initData, desc, basemap, recolormaskmap, ttmap0, hsfile0, ttmap1, hsfile1, ttmap2, hsfile2, ttmap3, hsfile3)
	local default_rotation = 0

	local mips, compress, alpha = 0, true, 1.0

	local skinToneType = initData.IsMannequin~=0 and 1 or initData.BodySkinToneType+1
	
	skinToneType = math.min(math.max(skinToneType,1),#PLAYER_SKINTONE_MALE_HSL_LIST)

	local skinHSL = PLAYER_SKINTONE_MALE_HSL_LIST[skinToneType]
	local skinLevel = PLAYER_SKINTONE_MALE_LEVEL_LIST[skinToneType]

	local hsdata0 = _readGenericHotspotData(hsfile0, "bodyupper", "rightarm")
	local hsdata1 = _readGenericHotspotData(hsfile1, "bodyupper", "leftarm")
	local hsdata2 = _readGenericHotspotData(hsfile2, "bodyupper", "back")
	local hsdata3 = _readGenericHotspotData(hsfile3, "bodyupper", "front")

	local blendvalues0 = _readTattooBlendModeData(hsfile0, "bodyupper", "blendmode")
	local blendvalues1 = _readTattooBlendModeData(hsfile1, "bodyupper", "blendmode")
	local blendvalues2 = _readTattooBlendModeData(hsfile2, "bodyupper", "blendmode")
	local blendvalues3 = _readTattooBlendModeData(hsfile3, "bodyupper", "blendmode")
	
	local blendmode0 = _getBlendMode(initData.BodySkinToneType, blendvalues0)
	local blendmode1 = _getBlendMode(initData.BodySkinToneType, blendvalues1)
	local blendmode2 = _getBlendMode(initData.BodySkinToneType, blendvalues2)
	local blendmode3 = _getBlendMode(initData.BodySkinToneType, blendvalues3)

	local cryoblendmode0 = _getCryoBlendmode(blendmode0)
	local cryoblendmode1 = _getCryoBlendmode(blendmode1)
	local cryoblendmode2 = _getCryoBlendmode(blendmode2)
	local cryoblendmode3 = _getCryoBlendmode(blendmode3)

	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(basemap, "basemap")
	cryoResourceMap:addTexture(recolormaskmap, "recolormask")
	cryoResourceMap:addTexture(ttmap0, "ttmap0")
	cryoResourceMap:addTexture(ttmap1, "ttmap1")
	cryoResourceMap:addTexture(ttmap2, "ttmap2")
	cryoResourceMap:addTexture(ttmap3, "ttmap3")

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "basemap")
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)
	cryoLayer:setMaskTexture("recolormask")
	cryoLayer:setMaskMode(enum.CryoTextureMaskMode_LimitAdjustments)
	cryoLayer:setHslParams(skinHSL)
	cryoLayer:setLevelAdjustment(unpack(skinLevel))

	cryoLayer = cryoRecipe:addTextureLayer(nil, "ttmap0")
	cryoLayer:setLegacyPlacement(hsdata0.Bounds, hsdata0.Rotation)
	cryoLayer:setBlending(cryoblendmode0)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "ttmap1")
	cryoLayer:setLegacyPlacement(hsdata1.Bounds, hsdata1.Rotation)
	cryoLayer:setBlending(cryoblendmode1)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "ttmap2")
	cryoLayer:setLegacyPlacement(hsdata2.Bounds, hsdata2.Rotation)
	cryoLayer:setBlending(cryoblendmode2)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "ttmap3")
	cryoLayer:setLegacyPlacement(hsdata3.Bounds, hsdata3.Rotation)
	cryoLayer:setBlending(cryoblendmode3)

	local cryoCompositor = createCryoTextureCompositor("BodyUpperTattoo", 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-----------------------------------------------------------------------------
local function _compositeBodyLowerTattoo(initData, desc, basemap, recolormaskmap, ttmap0, hsfile0, ttmap1, hsfile1)
	local default_rotation = 0

	local mips, compress, alpha = 0, true, 1.0

	
	local skinToneType = initData.IsMannequin~=0 and 1 or initData.BodySkinToneType+1

	skinToneType = math.min(math.max(skinToneType,1),#PLAYER_SKINTONE_MALE_HSL_LIST)

	local skinHSL = PLAYER_SKINTONE_MALE_HSL_LIST[skinToneType]
	local skinLevel = PLAYER_SKINTONE_MALE_LEVEL_LIST[skinToneType]

	local hsdata0 = _readGenericHotspotData(hsfile0, "bodylower", "rightleg")
	local hsdata1 = _readGenericHotspotData(hsfile1, "bodylower", "leftleg")

	local blendvalues0 = _readTattooBlendModeData(hsfile0, "bodyupper", "blendmode")
	local blendvalues1 = _readTattooBlendModeData(hsfile1, "bodyupper", "blendmode")
		
	local blendmode0 = _getBlendMode(initData.BodySkinToneType, blendvalues0)
	local blendmode1 = _getBlendMode(initData.BodySkinToneType, blendvalues1)

	local cryoblendmode0 = _getCryoBlendmode(blendmode0)
	local cryoblendmode1 = _getCryoBlendmode(blendmode1)
	
	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(basemap, "basemap")
	cryoResourceMap:addTexture(recolormaskmap, "recolormask")
	cryoResourceMap:addTexture(ttmap0, "ttmap0")
	cryoResourceMap:addTexture(ttmap1, "ttmap1")

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "basemap")
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)
	cryoLayer:setMaskTexture("recolormask")
	cryoLayer:setMaskMode(enum.CryoTextureMaskMode_LimitAdjustments)
	cryoLayer:setHslParams(skinHSL)
	cryoLayer:setLevelAdjustment(unpack(skinLevel))

	cryoLayer = cryoRecipe:addTextureLayer(nil, "ttmap0")
	cryoLayer:setLegacyPlacement(hsdata0.Bounds, hsdata0.Rotation)
	cryoLayer:setBlending(cryoblendmode0)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "ttmap1")
	cryoLayer:setLegacyPlacement(hsdata1.Bounds, hsdata1.Rotation)
	cryoLayer:setBlending(cryoblendmode1)

	local cryoCompositor = createCryoTextureCompositor("BodyLowerTattoo", 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-----------------------------------------------------------------------------
local function _compositeBodyUpperCullMask(initData, desc, cullmap0, cullmap1, cullmap2, cullmap3, cullmap4, cullmap5)
	local mips, compress, alpha = 0, true, 1.0

	local defaultHotspot = {0, 0, 1.0, 1.0}
	local rotation = 0
	local laneId = initData.laneId
	
	if initData.UseSecondaryLaneForCullMask then
		local secondaryLaneId = getSecondaryLaneId()
		if secondaryLaneId ~= -1 then
			laneId = secondaryLaneId
		end
	end

	local cryoRecipe = createCryoTextureRecipe()
	local cryoResourceMap = createCryoTextureResourceMap()

	cryoResourceMap:addTexture(cullmap0, "cullmap0")
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap0")
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)

	cryoResourceMap:addTexture(cullmap1, "cullmap1")
	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap1")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	cryoResourceMap:addTexture(cullmap2, "cullmap2")
	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap2")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	cryoResourceMap:addTexture(cullmap3, "cullmap3")
	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap3")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)
	
	cryoResourceMap:addTexture(cullmap4, "cullmap4")
	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap4")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	cryoResourceMap:addTexture(cullmap5, "cullmap5")
	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap5")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	local cryoCompositor = createCryoTextureCompositor("BodyUpperCullMask", 0, desc.width, desc.height, mips, compress, desc.format, laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-----------------------------------------------------------------------------
local function _compositeBodyLowerCullMask(initData, desc, cullmap0, cullmap1, cullmap2, cullmap3)
	local mips, compress, alpha = 0, true, 1.0

	local defaultHotspot = {0, 0, 1.0, 1.0}
	local rotation = 0
	local laneId = initData.laneId
	
	if initData.UseSecondaryLaneForCullMask then
		local secondaryLaneId = getSecondaryLaneId()
		if secondaryLaneId ~= -1 then
			laneId = secondaryLaneId
		end
	end

	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(cullmap0, "cullmap0")
	cryoResourceMap:addTexture(cullmap1, "cullmap1")
	cryoResourceMap:addTexture(cullmap2, "cullmap2")
	cryoResourceMap:addTexture(cullmap3, "cullmap3")

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap0")
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap1")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap2")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	cryoLayer = cryoRecipe:addTextureLayer(nil, "cullmap3")
	cryoLayer:setBlending(enum.CryoBlendMode_Multiply)

	local cryoCompositor = createCryoTextureCompositor("BodyLowerCullMask", 0, desc.width, desc.height, mips, compress, desc.format, laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

-----------------------------------------------------------------------------
local function loadAccessoryCullMaps(initData, nocullMap )
	local acc_cullmask0, acc_cullmask1, acc_cullmask2 = nocullMap, nocullMap, nocullMap

	local gender = initData.Gender
	local model, colorid, side
	local cullmap_name
	
	for _, accessory in ipairs(initData.Accessories) do
		model = accessory.AccessoryModel
		colorid = accessory.AccessoryColor
		side = accessory.AccessoryVariation
		
		if model == sleevesid then
			cullmap_name = string.format("sleeve_%d_%d_%d_bodyuppercull", colorid, side, gender)
			if (side==0) then
				acc_cullmask0 = loadAsync(brts.accessory, cullmap_name, true, initData.laneId) or nocullMap
			else
				acc_cullmask1 = loadAsync(brts.accessory, cullmap_name, true, initData.laneId) or nocullMap
			end

		elseif model == gloveid then
			cullmap_name = string.format("glove_%d_%d_bodyuppercull", colorid, gender)
			acc_cullmask2 = loadAsync(brts.accessory, cullmap_name, true, initData.laneId) or nocullMap
		end
	end
	return acc_cullmask0, acc_cullmask1, acc_cullmask2
end

-----------------------------------------------------------------------------
local function loadUpperBody(items, generatedTextures, initData, args, assets)
	local allow_missing = true
	local disallow_missing = false
	local use_kit_body = initData.UsePlayerArms ~= 0
	local needs_compositing = false
	local headassetid = initData.IsCreatedPlayer ~= 0 and -1 or initData.HeadAssetId
	local skin_tone = initData.HeadSkinToneType
	local nogkgloves = (initData.IsGoalie == 0 and initData.UseKitGkGloves == 0) or initData.GkGloveType==-1
	local is_mannequin = initData.IsMannequin ~= 0

	local db_gender = initData.Gender
	-- load female body skin when players are children. 
	local is_child = _isChild(initData)
	local gender = is_child and 1 or db_gender
	
	-- texture names and loading
	local color_name_star = string.format("bodyupper_%d_%d_%d_color", headassetid, gender, initData.HeadVariation)
	local color_name_gen =  is_mannequin and string.format("bodyupper_0_%d_0_color", gender) or string.format("bodyupper_common_%d_recolor", gender) 

	local recolor_mask_name = string.format("bodyupper_common_%d_recolor_mask", gender)
	local normal_name = string.format("bodyupper_common_%d_normal", gender)
	local bent_normal_name = string.format("bodyupper_common_%d_normal_bent", gender)
	local coeff_name = string.format("bodyupper_common_%d_coeff", gender)
	local sss_name = "bodyupper_common_sss"
	local dirtmap_name = string.format("bodyupper_dk_%d", initData.DirtType)
	local dirtmask_name = "bodyupper_dk_region"
	local exertionNormal_name = string.format("bodyupper_common_%d_exertion_normal;debug_texture_normal", gender)
	local exertionCoeff_name = string.format("bodyupper_common_%d_exertion_coeff;debug_texture_coeff", gender)

	-- if the player has a custom colormap load it and don't composite.
	local colorMap = loadAsync(brts.body, color_name_star, allow_missing, initData.laneId)
	local recolorMaskMap = nil
	if colorMap==nil then
		-- load generic texture an composite to recolor 
		-- and stamp tattoos if any
		colorMap = loadAsync(brts.body, color_name_gen, false, initData.laneId)
		recolorMaskMap = loadAsync(brts.body, recolor_mask_name, false, initData.laneId)
		needs_compositing = true
	end

	local coeffMap = loadAsync(brts.body, coeff_name, false, initData.laneId)
	local normalMap = loadAsync(brts.body, normal_name, false, initData.laneId)
	local bentNormalMap = SETTING.UseSpecularOcclusion and loadAsync(brts.body, bent_normal_name, false, initData.laneId) or nil
	local dirtMap = loadAsync(brts.body, dirtmap_name, false, initData.laneId)
	local dirtMask = loadAsync(brts.body, dirtmask_name, false, initData.laneId)
	local sssMap = loadAsync(brts.body, sss_name, false, initData.laneId)
	local exertionNormalMap, exertionCoeffMap = nil, nil
	if SETTING.UseBodyExertion then
		exertionNormalMap = loadAsync(brts.body, exertionNormal_name, allow_missing, initData.laneId)
		exertionCoeffMap = loadAsync(brts.body, exertionCoeff_name, allow_missing, initData.laneId)
	end
	
	-- composite tattoos if necessary
	local generatedSkinMap = nil
	-- yury todo: there is no bools in initData
	if needs_compositing then
		local tattoo0, hotspot0 = _loadTattoo(initData.TattooRightArm, initData)
		local tattoo1, hotspot1 = _loadTattoo(initData.TattooLeftArm, initData)
		local tattoo2, hotspot2 = _loadTattoo(initData.TattooTorsoBack, initData)
		local tattoo3, hotspot3 = _loadTattoo(initData.TattooTorsoFront, initData)
		
		generatedSkinMap = futureCall(_compositeBodyUpperTattoo, initData, BodyCompositorDesc, colorMap, recolorMaskMap,
			tattoo0, hotspot0, tattoo1, hotspot1, tattoo2, hotspot2, tattoo3, hotspot3)

		generatedTextures[#generatedTextures + 1] = generatedSkinMap
	end	
	
	
	-- default cull mask
	local nocullMap = loadAsync(brts.body, "nocull", false, initData.laneId)
		
	local flexMask = nil
	local flexNormalMap = nil
	local flexAmbientMap = nil

	-- accessory cullmaps
	local acc_cullmap0, acc_cullmap1, acc_cullmap2 = loadAccessoryCullMaps(initData, nocullMap)
	
	-- goalie gloves cullmaps
	local gkgloves_cullmap = nocullMap
	if not nogkgloves then
		local gkgloves_cullmap_name = string.format('gkglove_%d_bodyuppercull', initData.GkGloveType)
		gkgloves_cullmap =loadAsync(brts.accessory, gkgloves_cullmap_name, allow_missing, initData.laneId) or nocullMap
	end

	-- flexmaps
	flexMask, flexNormalMap, flexAmbientMap = _loadMuscleFlexMaps(initData, "bodyupper_flex")
	
	if use_kit_body then
		-- cull mask generated texture
		-- besides the db driven asset, we always load the long sleeve version for use with warmup tops via cullmasks
		local longsleeve = 1
		local top0_cullmask_name = string.format("top_%d_%d_bodyuppercull", initData.ArmLength, gender)
		local top1_cullmask_name = string.format("top_%d_%d_bodyuppercull", longsleeve, gender) 
		local top0_cullMap = loadAsync(brts.body, top0_cullmask_name, allow_missing, initData.laneId) or nocullMap
		local top1_cullMap = loadAsync(brts.body, top1_cullmask_name, allow_missing, initData.laneId) or nocullMap
			
		local generatedCullMapSS = futureCall(_compositeBodyUpperCullMask, initData, CullMaskCompositorDesc, 
			top0_cullMap, nocullMap, gkgloves_cullmap, acc_cullmap0, acc_cullmap1, acc_cullmap2)
		generatedTextures[#generatedTextures + 1] = generatedCullMapSS

		local generatedCullMapLS = futureCall(_compositeBodyUpperCullMask, initData, CullMaskCompositorDesc, 
			top1_cullMap, nocullMap, gkgloves_cullmap, acc_cullmap0, acc_cullmap1, acc_cullmap2)
		generatedTextures[#generatedTextures + 1] = generatedCullMapLS

		-- mesh
		local bodyupper_name = SETTING.UseFullBody and string.format("bodyupper_%d_%d;bodyupper_%d", headassetid, gender, gender) or string.format("arms_0_0_%d", gender)
		local bodyupper_mesh = loadAsync(brts.body, bodyupper_name, disallow_missing, initData.laneId)
		
		-- bind the short sleeves
		items[#items + 1] = futureCall(bindUpperBody, initData, args, slots.arms, bodyupper_mesh,
									colorMap, coeffMap, normalMap, bentNormalMap, dirtMap, dirtMask, sssMap, generatedCullMapSS, generatedSkinMap, flexMask, flexNormalMap, flexAmbientMap, exertionNormalMap, exertionCoeffMap)
		-- bind the long sleeves
		items[#items + 1] = futureCall(bindUpperBody, initData, args, slots.arms_short, bodyupper_mesh,
									colorMap, coeffMap, normalMap, bentNormalMap, dirtMap, dirtMask, sssMap, generatedCullMapLS, generatedSkinMap, flexMask, flexNormalMap, flexAmbientMap, exertionNormalMap, exertionCoeffMap)

		assets.CullTextureMaskUpperBodyGenerated = generatedCullMapSS
	else
		local top0_cullmask_name = string.format("top_%d_%d_bodyuppercull", initData.TopBaseGeoId, gender)
		local top1_cullmask_name = string.format("top_%d_%d_bodyuppercull", initData.TopSecondLayerGeoId, gender)
		local top0_cullMap = loadAsync(brts.wardrobe, top0_cullmask_name, allow_missing, initData.laneId) or nocullMap
		local top1_cullMap = loadAsync(brts.wardrobe, top1_cullmask_name, allow_missing, initData.laneId) or nocullMap
		
		local generatedCullMap = futureCall(_compositeBodyUpperCullMask, initData, CullMaskCompositorDesc,
			top0_cullMap, top1_cullMap, gkgloves_cullmap, acc_cullmap0, acc_cullmap1, acc_cullmap2)
		generatedTextures[#generatedTextures + 1] = generatedCullMap

		local bodyupper_name = string.format("bodyupper_%d_%d;bodyupper_%d", headassetid, db_gender, db_gender)
		local bodyupper_mesh = loadAsync(brts.body, bodyupper_name, disallow_missing, initData.laneId)

		items[#items + 1] = futureCall(bindUpperBody, initData, args, slots.bodyupper, bodyupper_mesh, 
			colorMap, coeffMap, normalMap, bentNormalMap, dirtMap, dirtMask, sssMap, generatedCullMap, generatedSkinMap, flexMask, flexNormalMap, flexAmbientMap, exertionNormalMap, exertionCoeffMap)
			
		assets.CullTextureMaskUpperBodyGenerated = generatedCullMap
	end

end

-----------------------------------------------------------------------------
local function loadLowerBody(items, generatedTextures, initData, args, assets)
	if(initData.LegLength < 0 or initData.LegLength == 9999) then return end	
	local is_gkpants = initData.ShortStyle == 1 
	if(is_gkpants) then return end	
	
	local allow_missing = true
	local disallow_missing = false
	local use_kit_body = initData.UsePlayerLegs ~= 0
	local needs_compositing = false
	local headassetid = initData.IsCreatedPlayer ~= 0 and -1 or initData.HeadAssetId
	local skin_tone = initData.HeadSkinToneType
	-- local bodySkinTone = initData.IsMannequin~=0 and 0 or 2  -- 0 is mannequin--initData.BodySkinToneType
	local is_mannequin = initData.IsMannequin ~= 0

	local db_gender = initData.Gender
	
	-- load female skin when players are children.
	local is_child = _isChild(initData)
	local gender = is_child and 1 or db_gender 
	
	-- texture names and loading
	local color_name_star = string.format("bodylower_%d_%d_%d_color", headassetid, gender, initData.HeadVariation)
	local color_name_gen = is_mannequin and string.format("bodylower_0_%d_0_color", gender) or string.format("bodylower_common_%d_recolor", gender)

	local recolor_mask_name = string.format("bodylower_common_%d_recolor_mask", gender)
	local normal_name = string.format("bodylower_common_%d_normal", gender)
	local bent_normal_name = string.format("bodylower_common_%d_normal_bent", gender)
	local coeff_name = string.format("bodylower_common_%d_coeff", gender)
	local sss_name = "bodylower_common_sss"
	local dirtmap_name = string.format("bodylower_dk_%d", initData.DirtType)
	local dirtmask_name = "bodylower_dk_region"
	local exertionNormal_name = string.format("bodylower_common_%d_exertion_normal;debug_texture_normal", gender)
	local exertionCoeff_name = string.format("bodylower_common_%d_exertion_coeff;debug_texture_coeff", gender)

	-- if the player has a custom colormap load it and don't composite.
	local colorMap = loadAsync(brts.body, color_name_star, allow_missing, initData.laneId)
	local recolorMaskMap = nil
	if colorMap==nil then
		-- load generic texture an composite to recolor 
		-- and stamp tattoos if any
		colorMap = loadAsync(brts.body, color_name_gen, false, initData.laneId)
		recolorMaskMap = loadAsync(brts.body, recolor_mask_name, false, initData.laneId)
		needs_compositing = true
	end

	local coeffMap = loadAsync(brts.body, coeff_name, false, initData.laneId)
	local normalMap = loadAsync(brts.body, normal_name, false, initData.laneId)
	local bentNormalMap = SETTING.UseSpecularOcclusion and loadAsync(brts.body, bent_normal_name, false, initData.laneId) or nil
	local dirtMap = loadAsync(brts.body, dirtmap_name, false, initData.laneId)
	local dirtMask = loadAsync(brts.body, dirtmask_name, false, initData.laneId)
	local sssMap = loadAsync(brts.body, sss_name, false, initData.laneId)
	local exertionNormalMap, exertionCoeffMap = nil, nil
	if SETTING.UseBodyExertion then
		exertionNormalMap = loadAsync(brts.body, exertionNormal_name, allow_missing, initData.laneId)
		exertionCoeffMap = loadAsync(brts.body, exertionCoeff_name, allow_missing, initData.laneId)
	end

	-- composite tattoos if necessary
	local generatedSkinMap = nil

	if needs_compositing then
		local tattoo0, hotspot0 = _loadTattoo(initData.TattooRightLeg, initData)
		local tattoo1, hotspot1 = _loadTattoo(initData.TattooLeftLeg, initData)
	
		generatedSkinMap = futureCall(_compositeBodyLowerTattoo, initData, BodyCompositorDesc, colorMap, recolorMaskMap,
			tattoo0, hotspot0, tattoo1, hotspot1)

		generatedTextures[#generatedTextures + 1] = generatedSkinMap
	end
	
	
	local slot
	local flexMask = nil
	local flexNormalMap = nil
	local flexAmbientMap = nil

	-- cull mask generated texture
	local nocullMap = loadAsync(brts.body, "nocull", disallow_missing, initData.laneId)
	local sock_cullmask_name = string.format("sock_%d_%d_%d_bodylowercull", initData.SockLength, initData.SockStyle, gender)
	local shoe_cullmask_name = string.format("shoe_%d_0_bodylowercull", initData.ShoeType)
	local bottom0_cullmask_name, bottom1_cullmask_name
	local bottom0_cullMap, bottom1_cullMap
	local sock_cullMap, shoe_cullMap
	flexMask, flexNormalMap, flexAmbientMap = _loadMuscleFlexMaps(initData, "bodylower_flex")

	if use_kit_body then
		slot = slots.legs
		
		local bottom0_cullmask_name = string.format("bottom_%d_%d_bodylowercull", initData.ShortStyle, gender)
		--local bottom1_cullmask_name = string.format("bottom_%d_%d_bodylowercull", initData.BottomSecondLayerId, gender)
		bottom0_cullMap = loadAsync(brts.body, bottom0_cullmask_name, allow_missing, initData.laneId) or nocullMap
		bottom1_cullMap = nocullMap
		sock_cullMap = loadAsync(brts.body, sock_cullmask_name, allow_missing, initData.laneId) or nocullMap
		shoe_cullMap = loadAsync(brts.shoes, shoe_cullmask_name, allow_missing, initData.laneId) or nocullMap

	else
		slot = slots.bodylower
		local bottom0_cullmask_name = string.format("bottom_%d_%d_bodylowercull", initData.BottomGeoId, gender)
		local bottom1_cullmask_name = string.format("bottom_%d_%d_bodylowercull", initData.BottomSecondLayerGeoId, gender)
		bottom0_cullMap = loadAsync(brts.wardrobe, bottom0_cullmask_name, allow_missing, initData.laneId) or nocullMap
		bottom1_cullMap = loadAsync(brts.wardrobe, bottom1_cullmask_name, allow_missing, initData.laneId) or nocullMap
		sock_cullMap = loadAsync(brts.wardrobe, sock_cullmask_name, allow_missing, initData.laneId) or nocullMap
		shoe_cullMap = loadAsync(brts.shoes, shoe_cullmask_name, allow_missing, initData.laneId) or nocullMap

	end

	local generatedCullMap = futureCall(_compositeBodyLowerCullMask, initData, CullMaskCompositorDesc, bottom0_cullMap, bottom1_cullMap, sock_cullMap, shoe_cullMap)
	generatedTextures[#generatedTextures + 1] = generatedCullMap

	assets.CullTextureMaskLowerBodyGenerated = generatedCullMap;

	local bodylower_name = string.format("bodylower_%d", db_gender)
	local bodylower_mesh = loadAsync(brts.body, bodylower_name, disallow_missing, initData.laneId)
	if bodylower_mesh then
		items[#items+1] = futureCall(bindLowerBody, initData, args, slot, bodylower_mesh,
				colorMap, coeffMap, normalMap, bentNormalMap, dirtMap, dirtMask, sssMap, generatedCullMap, generatedSkinMap, flexMask, flexNormalMap, flexAmbientMap, exertionNormalMap, exertionCoeffMap)
	end
end

-----------------------------------------------------------------------------
local function _loadStarHead(items, initData, args, exertionCoeffMap, exertionNormalMap, sssMap, wrinkleMaskMap)
	local gender = initData.Gender
	local head = initData.HeadAssetId
	local headclass = 0 -- initData.HeadClass
	local head_variation = initData.HeadVariation

	--local head_name = string.format("head_%d_0_%d;head_0_1_0", head, head_variation)
	local head_name = string.format("head_%d_0_%d", head, head_variation)
	local fallback_head_name = string.format("basehead_%d", gender) -- comes from another brt
	local fallback_face_name = string.format("skin_base_%d_color;skin_base_2_color", initData.BodySkinToneType) -- comes from another brt

	local head_mesh = loadAsync(brts.starhead, head_name, true, initData.laneId) -- or loadAsync(brts.generichead, fallback_head_name, false, initData.laneId)

	if not head_mesh then return false end
	
	
	
	local color_name = string.format("face_%d_0_%d_color", head, head_variation)
	local base_normal = string.format("face_%d_0_%d_normal;head_common_%d_normal;debug_texture_normal", head, head_variation, gender)
	local wrinkle_normal = string.format("face_expression_%d_0_%d_normal;head_expression_%d_normal;debug_texture_normal_array", head, head_variation, gender)
	local coeff_name = string.format("head_common_%d_coeff;debug_texture_coeff", gender)
	local ao_name = string.format("face_expression_%d_0_%d_ambient;head_expression_%d_ambient;debug_texture_aoblend", head, head_variation, gender)
	local specmask_name = string.format("face_%d_0_%d_specmask;head_common_sk_coeff", head, head_variation)
	local bent_normal_name = string.format("head_common_%d_normal_bent;debug_texture_normal", gender)

	local colorMap = loadAsync(brts.starhead, color_name, true, initData.laneId) or loadAsync(brts.generichead, fallback_face_name, false, initData.laneId)
	local normalMap = loadAsync(brts.starhead, base_normal, false, initData.laneId)
	local bentNormalMap = SETTING.UseSpecularOcclusion and loadAsync(brts.starhead, bent_normal_name, false, initData.laneId) or nil
	local wrinkleNormalMap = loadAsync(brts.starhead, wrinkle_normal, false, initData.laneId)
	local coeffMap = loadAsync(brts.base, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(brts.starhead, ao_name, false, initData.laneId)
	local specMaskMap = loadAsync(brts.starhead, specmask_name, false, initData.laneId)

	local eye_name = "eye_common_color"
	local eyeMap = loadAsync(brts.base, eye_name, false, initData.laneId)
	
	local cull_name = "nocull"
	local brts_name = brts.body
	
	if SETTING.UseHighresMouthbag then
		local mouthbag_mesh_name = string.format("mouthbag_%d_%d_%d", head, headclass, head_variation)
		local mouthbag_mesh = loadAsync(brts.starhead, mouthbag_mesh_name, true, initData.laneId)
		
		if mouthbag_mesh then 

			cull_name = "head_common_cullmask"
			brts_name = brts.base
			
			local mouthbag_color_name = string.format("mouthbag_common_%d_color", PLAYER_GUM_COLOR_LIST[initData.HeadSkinToneType])
			
			local mouthbagColorMap = loadAsync(brts.base, mouthbag_color_name, false, initData.laneId)
			local mouthbagCoeffMap = loadAsync(brts.base, "mouthbag_common_coeff", false, initData.laneId)
			local mouthbagNormalMap = loadAsync(brts.base, "mouthbag_common_normal", false, initData.laneId)
			local mouthbagBentNormalMap = loadAsync(brts.base, "mouthbag_common_bent", false, initData.laneId)
			local mouthbagSssMap = loadAsync(brts.base, "mouthbag_common_sss", false, initData.laneId)

			items[#items + 1] = futureCall(bindMouthbag, initData, args, mouthbag_mesh, mouthbagColorMap, mouthbagCoeffMap, mouthbagNormalMap, mouthbagBentNormalMap, mouthbagSssMap)
		end
	end

	local cullMap = loadAsync(brts_name, cull_name, false, initData.laneId)

	-- schedule a function that builds the head to run once all the loads above are complete
	items[#items + 1] = futureCall(bindHead, initData, args, head_mesh,  
			colorMap, nil, normalMap, nil, bentNormalMap, wrinkleNormalMap, coeffMap, nil, aoMap, 
			specMaskMap, nil, exertionCoeffMap, exertionNormalMap, sssMap, wrinkleMaskMap, eyeMap, false, cullMap)
	
	return true
end

local function _loadEyeLashes(items, initData)
	-- don't load this on mobile
	if IS_MOBILE then return end

	local allow_missing = true
	local headclass = 1 -- always generic
	local variation = 0
	local gender = initData.Gender
	local eyelash_name = string.format("eyelash_%d_%d_%d", variation, headclass, gender)
	local eyelash_mesh = loadAsync(brts.generichead, eyelash_name, allow_missing, initData.laneId)
	items[#items + 1] = futureCall(bindeyelash, initData, eyelash_mesh)	
end

-----------------------------------------------------------------------------
local function _compositeCraniumTexture(initData, generatedTextures, convertedRecipe, textureType)
	assert(convertedRecipe ~= nil)
	assert(convertedRecipe:queryCryoRecipeCount() > 0)

	local cryoResourceMap = convertedRecipe:getCryoResourceMap()
	local cryoRecipe = nil
	local colorEncoding = enum.CryoColorEncoding_Linear	

	local textureTypeNames = convertedRecipe:getTextureTypeNames()
	for _, recipeName in ipairs(textureTypeNames) do
		if recipeName == textureType then
			cryoRecipe = convertedRecipe:getCryoRecipe(recipeName)
			colorEncoding = convertedRecipe:getTextureEncoding(recipeName)
			break
		end
	end

	assert(cryoResourceMap ~= nil)
	assert(cryoRecipe ~= nil)
	assert(colorEncoding == enum.CryoColorEncoding_Linear or colorEncoding == enum.CryoColorEncoding_NormalMap)

	local mips, compress = 0, true
	local desc = FaceCompositorDesc
	local texture_format = desc.format
	local texture_name = "cranium_material_" .. textureType

	if (colorEncoding == enum.CryoColorEncoding_NormalMap) then
		texture_format = enum.RenderFormat_BC5_UNORM
	end

	local cryoCompositor = createCryoTextureCompositor(texture_name, 0, desc.width, desc.height, mips, compress, texture_format, initData.laneId)
	cryoCompositor:setColorEncoding(colorEncoding)
	local craniumTexture = cryoCompositor:composite(cryoResourceMap, cryoRecipe)

	generatedTextures[#generatedTextures + 1] = craniumTexture
	return craniumTexture
end

local function _compositeCraniumTextures(initData, generatedTextures)
	local albedo, normal, coeff = nil, nil, nil

	local isCreatedPlayer = initData.IsCreatedPlayer ~= 0
	local useCraniumMaterialRecipe = isCreatedPlayer and SETTING.UseCraniumMaterialRecipe

	if useCraniumMaterialRecipe then
		decalLibrary = getCraniumHeadDecalLibrary()
		materialRecipe = getCraniumMaterialRecipe(initData.PlayerId)

		if decalLibrary ~= nil and materialRecipe ~= nil then
			local cryoConverter = createCraniumCryoTranslator()
			local convertedRecipeFuture = cryoConverter:convertCraniumMaterialRecipe(materialRecipe, decalLibrary)
			local textureTypeNames = cryoConverter:getPotentialTextureTypeNames()

			for _, textureType in ipairs(textureTypeNames) do
				if textureType == "albedo" then
					albedo = futureCall(_compositeCraniumTexture, initData, generatedTextures, convertedRecipeFuture, textureType)
				elseif textureType == "normal" then
					normal = futureCall(_compositeCraniumTexture, initData, generatedTextures, convertedRecipeFuture, textureType)
				elseif textureType == "coeff" then
					coeff = futureCall(_compositeCraniumTexture, initData, generatedTextures, convertedRecipeFuture, textureType)
				end
			end
		end
	end

	return albedo, normal, coeff
end

-----------------------------------------------------------------------------

local function _loadGenericHead(items, generatedTextures, initData, args, 
								exertionCoeffMap, exertionNormalMap, 
								sssMap, wrinkleMaskMap,
								assets, highresFanColorGenMap)

	local headclass    = 1
	local gender       = initData.Gender
	local skin_tone    = initData.HeadSkinToneType
	local skin_type    = initData.HeadSkinType
	local complexion   = initData.HeadSkinComplexion
	local lip_color    = initData.LipColor
	local makeup       = initData.Makeup
	local eye_detail   = initData.EyeDetail
	local eyebrow      = initData.Eyebrow
	local surface_pack = initData.HeadSurfacePack

	local eyecolor     = initData.EyeColor
	local surface_pack_fallback = (gender == 0) and 220001 or 122101
	local facialhair_type = args.stamp_beard and initData.FacialHairType or 0
	local is_mannequin = initData.IsMannequin~=0
	local allow_missing = true


	if is_mannequin then
		skin_tone,skin_type,complexion,lip_color,makeup,eye_detail,eyecolor,eyebrow,surface_pack=0,0,0,0,0,0,0,0,0
	end
	
	skin_tone = math.min(math.max(skin_tone,1),#PLAYER_SKINTONE_MALE_HSL_LIST)
	
	local skinbase_name = string.format("skin_base_%d_color;skin_base_2_color", complexion)
	local skincomplexion_name = string.format("skin_complexion_%d_color;skin_none_color", complexion)
	local skintype_name = string.format("skin_variation_%d_color;skin_none_color", skin_type)
	local eyedetail_name = string.format("eyedetail_%d_color;skin_none_color", eye_detail)
	local makeup_name = string.format("skin_makeup_%d_color;skin_none_color", makeup)
	
	local torso_color_name = is_mannequin and "skin_none_color" or string.format("torso_common_%d_color", gender)
	local torso_coeff_name = "torso_common_0_coeff"
	local torso_normal_name = string.format("torso_common_%d_normal", gender)
	
	local mouthbag_name = is_mannequin and "skin_none_color" or "mouthbag_common_color"
	local skinmask_name = is_mannequin and "skin_none_color" or "skin_recolor_mask" 
	local lips_base_name = (is_mannequin or lip_color == 0) and "skin_none_color" or "lips_base_0_color"

	
	local surfacenormalmask_name = "skin_surface_normal_mask"
	local facialhaircolor_name = string.format("facialhair_%d_color;facialhair_0_color", facialhair_type)
	local facialhairambient_name = string.format("facialhair_%d_ambient;facialhair_0_ambient", facialhair_type)

	local browcolor_name = string.format("eyebrows_%d_color;facialhair_0_color",eyebrow)
	local browambient_name = string.format("eyebrows_%d_ambient;facialhair_0_ambient",eyebrow)

	local hairline_name = string.format("hair_%d_%d_%d_hairline", initData.Hair, headclass, initData.HairStyle)
	local hairscalp_name = string.format("hair_%d_%d_%d_scalp", initData.Hair, headclass, initData.HairStyle)

	local skinBaseMap = loadAsync(brts.generichead, skinbase_name, false, initData.laneId)
	local skinComplexionMap = loadAsync(brts.generichead, skincomplexion_name, false, initData.laneId)
	local skinTypeMap = loadAsync(brts.generichead, skintype_name, false, initData.laneId)
	local eyeDetailMap = loadAsync(brts.generichead, eyedetail_name, false, initData.laneId)
	local makeupMap = loadAsync(brts.generichead, makeup_name, false, initData.laneId)

	local torsoColorMap = loadAsync(brts.generichead, torso_color_name, false, initData.laneId)
	local torsoCoeffMap = loadAsync(brts.generichead, torso_coeff_name, false, initData.laneId)
	local torsoNormalMap = loadAsync(brts.generichead, torso_normal_name, false, initData.laneId)

	local mouthbagMap = loadAsync(brts.generichead, mouthbag_name, false, initData.laneId)
	local skinMaskMap = loadAsync(brts.generichead, skinmask_name, false, initData.laneId)
	local lipsBaseMap = loadAsync(brts.generichead, lips_base_name, false, initData.laneId)

	
	local surfaceNormalMaskMap = loadAsync(brts.generichead, surfacenormalmask_name, false, initData.laneId)

	local facialhairColorMap = loadAsync(brts.generichead, facialhaircolor_name, false, initData.laneId)
	local facialhairAmbientMap = loadAsync(brts.generichead, facialhairambient_name, false, initData.laneId)

	local browColorMap = loadAsync(brts.generichead, browcolor_name, false, initData.laneId)
	local browAmbientMap = loadAsync(brts.generichead, browambient_name, false, initData.laneId)

	local hairlineMap = loadAsync(brts.generichead, hairline_name, allow_missing, initData.laneId)
	local scalpMap = loadAsync(brts.generichead, hairscalp_name, allow_missing, initData.laneId)


	local surfacecavity_name = string.format("surface_%d_cavity;surface_%d_cavity", surface_pack, surface_pack_fallback)
	local surfaceambient_name = string.format("surface_%d_ambient;surface_%d_ambient", surface_pack, surface_pack_fallback)
	--local surfacenormal_name = string.format("surface_%d_normal;surface_%d_normal", surface_pack, surface_pack_fallback)
	
	local surfaceCavityMap = loadAsync(brts.generichead, surfacecavity_name, false, initData.laneId)
	--local surfaceAmbientMap = loadAsync(brts.generichead, surfaceambient_name, false, initData.laneId)
	--local surfaceNormalMap = loadAsync(brts.generichead, surfacenormal_name, false, initData.laneId)

	local tattooMap, hotspot = _loadTattoo(initData.TattooHead, initData)

	local normalMap, coeffMap, specMaskMap = nil
	local faceGenMap, normalGenMap, coeffGenMap, specMaskGenMap = nil, nil, nil, nil

	local isHighresFan = false
	if highresFanColorGenMap ~= nil then
		faceGenMap = highresFanColorGenMap
		isHighresFan = true
	else
		faceGenMap, normalGenMap, coeffGenMap = _compositeCraniumTextures(initData, generatedTextures)

		if faceGenMap == nil then
			local player_age = initData.Age
			args["playerAge"] = player_age == nil and 20 or player_age
			args["skintone"] = skin_tone == nil and 1 or skin_tone
			args["lipcolor"] = lip_color == nil and 0 or lip_color
			
			
			
			local idx = 0
			
			local surface_weights = {}
			local surface_normal_names = {}
			local surface_cavity_names = {}
			local surface_ambient_names = {}
			
			local surface_masks_names = {}
			
			-- Surface Pack Regions
			--[[ local test_regions = {
				{TextureId = 224001, Weight = 1.0},
				{TextureId = 263201, Weight = 1.0},
				{TextureId = 241101, Weight = 1.0},
				{TextureId = 250201, Weight = 1.0},
				{TextureId = 263201, Weight = 1.0},
				{TextureId = 143101, Weight = 1.0},
				{TextureId = 263201, Weight = 1.0},
				{TextureId = 242102, Weight = 1.0}
			}]]
			--for _,region in ipairs(test_regions) do
			for _,region in ipairs(initData.SurfaceRegions) do
				local texture_id=region.TextureId
				local weight = region.Weight
				if texture_id > 0 and weight > 0 then
					idx=#surface_normal_names+1
					surface_normal_names[idx]  = string.format("surface_%d_normal;surface_%d_normal",   texture_id, surface_pack_fallback)
					surface_cavity_names[idx]  = string.format("surface_%d_cavity;surface_%d_cavity",   texture_id, surface_pack_fallback)
					surface_ambient_names[idx] = string.format("surface_%d_ambient;surface_%d_ambient", texture_id, surface_pack_fallback)

					surface_masks_names[idx] = "mask_"..idx-1
					surface_weights[idx] = region.Weight
				end
			end

			local surface_normal_batch =  loadBatchAsync(brts.generichead, surface_normal_names)
			local surface_cavity_batch =  loadBatchAsync(brts.generichead, surface_cavity_names)
			local surface_ambient_batch = loadBatchAsync(brts.generichead, surface_ambient_names)
			local surface_masks_batch =   loadBatchAsync(brts.generichead, surface_masks_names)

			-- Secondary Forms
			local secondary_forms_weights = {}
			local secondary_forms_names = {}
			idx=0
			for i,region in ipairs(initData.SecondaryForms) do
				local texture_id = region.TextureId
				local weight = region.Weight
				local region_name = SecondaryFormsNames[i]

				if texture_id > 0 and weight > 0 and region_name ~= nil then 
					local texture_name = string.format("secondary_forms_%s_%d_normal;skin_none_normal", region_name, texture_id)
					idx=#secondary_forms_names+1
					secondary_forms_names[idx]   = texture_name
					secondary_forms_weights[idx] = weight
				end
			end

			secondary_forms_batch = loadBatchAsync(brts.generichead, secondary_forms_names)
			
			
			-- Color Map
			faceGenMap = futureCall(
				_compositeFaceMap, initData, args, 
				skinMap, skinBaseMap, skinComplexionMap, skinTypeMap, eyeDetailMap, makeupMap, torsoColorMap, 
				mouthbagMap, skinMaskMap, lipsBaseMap, surfaceCavityMap, 
				facialhairColorMap, facialhairAmbientMap, browColorMap, browAmbientMap, scalpMap, hairlineMap,
				tattooMap, hotspot
			)

			generatedTextures[#generatedTextures + 1] = faceGenMap

			-- Coeff Map
			specMaskGenMap = futureCall(
				_compositeFaceSkMap, initData, args, 
				surface_cavity_batch, surface_ambient_batch, surface_masks_batch,
				browColorMap, browAmbientMap, facialhairColorMap, facialhairAmbientMap,
				scalpMap, torsoCoeffMap
			)
			
			generatedTextures[#generatedTextures + 1] = normalGenMap
			
			-- Normal Map
			normalGenMap = futureCall(
				_compositeFaceNormalMap, initData, args,
				torsoNormalMap, surfaceNormalMaskMap,
				surface_normal_batch , surface_masks_batch, surface_weights, 
				secondary_forms_batch, secondary_forms_weights
			)
			
			generatedTextures[#generatedTextures + 1] = specMaskGenMap
			

			

		end
	end
	
	-- yury todo: create player
	-- local head_name = string.format("head_%d_1_0;head_0_1_0", initData.Head)
	local cp_head_name = string.format("basehead_%d", gender)
	if SETTING.UseCraniumHead then
		cp_head_name = string.format("cranium_fbmorph_preset_%d", gender)
	end
	--local head_mesh = initData.IsCreatedPlayer == 0 and loadAsync(brts.generichead, head_name, false, initData.laneId) or emptyRef()
	--local head_mesh = initData.IsCreatedPlayer == 0 and loadAsync(brts.generichead, head_name, false, initData.laneId) or nil
	--local head_mesh = initData.IsCreatedPlayer == 0 and loadAsync(brts.generichead, head_name, false, initData.laneId) or loadAsync(brts.generichead, cp_head_name, false, initData.laneId)
	local head_mesh = loadAsync(brts.generichead, cp_head_name, false, initData.laneId)

	if not SETTING.UseCraniumHead then
		local head_morph_name = string.format("headmorphtarget_%d_1_0;headmorphtarget_0_1_0", initData.Head)
		assets.GenericHeadMorphTarget = loadAsync(brts.genericheadmorph, head_morph_name, false, initData.laneId)
	end

	local base_normal = string.format("head_generic_%d_%d_normal;head_common_%d_normal", skin_tone, skin_type, gender)
	local wrinkle_normal = string.format("surface_%d_expression_normal;head_expression_%d_normal", surface_pack , gender)
	local ao_name = string.format("surface_%d_expression_ambient;head_expression_%d_ambient",surface_pack , gender)
	local coeff_name = string.format("head_common_%d_coeff", gender)
	local specmask_name = string.format("head_generic_%d_%d_specmask;head_common_sk_coeff", skin_tone, skin_type)
	local bent_normal_name = string.format("head_common_%d_normal_bent;debug_texture_normal", gender)

	if normalGenMap == nil then
		normalMap = loadAsync(brts.generichead, base_normal, false, initData.laneId)
	end

	if coeffGenMap == nil then
		coeffMap = loadAsync(brts.base, coeff_name, false, initData.laneId)
	end

	if specMaskGenMap == nil then
		specMaskMap = loadAsync(brts.generichead, specmask_name, false, initData.laneId)
	end

	local bentNormalMap = SETTING.UseSpecularOcclusion and loadAsync(brts.starhead, bent_normal_name, false, initData.laneId) or nil
	local wrinkleNormalMap = loadAsync(brts.base, wrinkle_normal, false, initData.laneId)
	local aoMap = loadAsync(brts.base, ao_name, false, initData.laneId)
		  
	--local eye_name = string.format("eye_%d_1_color;eye_1_1_color", initData.EyeColor)
	local eye_name = is_mannequin and "eye_0_1_color" or "eye_common_color" 
	local eyeMap = loadAsync(brts.base, eye_name, false, initData.laneId)
	
	local cull_name = "nocull"
	local cullMap = SETTING.UseHighresMouthbag and loadAsync(brts.body, cull_name, false, initData.laneId) or nil 
	items[#items + 1] = futureCall(bindHead, initData, args, head_mesh, 
			nil, faceGenMap, normalMap, normalGenMap, bentNormalMap, wrinkleNormalMap, coeffMap, coeffGenMap, aoMap, 
			specMaskMap, specMaskGenMap, exertionCoeffMap, exertionNormalMap, sssMap, wrinkleMaskMap, eyeMap, isHighresFan, cullMap)
end

-----------------------------------------------------------------------------
local function _loadSculptControlShapes(items, initData, args)
	local sculptShapes = nil

	if initData.CraniumHead.SculptShapes == 1 then
		sculptShapes = loadBatchAsync(brts.sculpt, SculptShapeNames_Fat)
	elseif initData.CraniumHead.SculptShapes == 2 then
		sculptShapes = loadBatchAsync(brts.sculpt, SculptShapeNames_Flesh)
	elseif initData.CraniumHead.SculptShapes == 3 then
		sculptShapes = loadBatchAsync(brts.sculpt, SculptShapeNames_Skeletal)
	elseif initData.CraniumHead.SculptShapes == 4 then
		sculptShapes = loadBatchAsync(brts.sculpt, SculptShapeNames_Secondary)
	end

	if sculptShapes ~= nil then
		items[#items + 1] = futureCall(bindSculptControlShapes, initData, args, sculptShapes)
	end
end

-----------------------------------------------------------------------------
local function loadHead(items, generatedTextures, initData, args, assets, highresFanColorGenMap)
	-- lods 
	local gender = initData.Gender
	local skin_tone = initData.HeadSkinToneType
	local isCreatedPlayer = initData.IsCreatedPlayer ~= 0
	
	-- common textures
	local exertionCoeffMap = loadAsync(brts.base, "head_common_exertion_coeff", false, initData.laneId)
	local exertionNormalMap = loadAsync(brts.base, "head_common_exertion_normal", false, initData.laneId)
	local sssMap = loadAsync(brts.base, "head_common_sss", false, initData.laneId)
	local wrinkleMaskMap = loadAsync(brts.base, "head_mask_normal", false, initData.laneId)

	-- if create player LoadCap and LoadFaceTextures
	local starhead_found=false
	if initData.HeadClass == 0 then
		starhead_found = _loadStarHead(items, initData, args,
					  exertionCoeffMap, exertionNormalMap, sssMap, wrinkleMaskMap)
	end		
	

	if not starhead_found then
		args.force_generic = true;
		_loadGenericHead(items, generatedTextures, initData, args, 
						 exertionCoeffMap, exertionNormalMap, sssMap, wrinkleMaskMap, assets, highresFanColorGenMap)

		if initData.IsMannequin~=1 and args.disable_eyelashes ~= true then
			_loadEyeLashes(items, initData)
		end

		_loadSculptControlShapes(items, initData, args)
	end
end


-----------------------------------------------------------------------------
local function loadHair(items, initData, args)
	local head_class = args.force_generic and 1 or initData.HeadClass
	local hair_id  = head_class == 0 and initData.HeadAssetId or initData.Hair
	local hair_brt = head_class == 0 and brts.starhead or brts.generichead
	local hair_style = initData.HairStyle

	local hair_name = string.format("hair_%d_%d_%d", hair_id, head_class, hair_style)
	local haircap_name = string.format("haircap_%d_%d_%d", hair_id, head_class, hair_style)
	local hair_accessory_name = string.format("hair_accessory_%d_%d_%d", hair_id, head_class, hair_style)

	local allow_missing = true
		
	local hair_mesh = loadAsync(hair_brt, hair_name, allow_missing, initData.laneId)
	local haircap_mesh = loadAsync(hair_brt, haircap_name, allow_missing, initData.laneId)
	local hair_accessory_mesh = loadAsync(hair_brt, hair_accessory_name, allow_missing, initData.laneId)

	if hair_mesh then
		items[#items + 1] = futureCall(bindHairItem, initData, args, hair_mesh)
	end

	if haircap_mesh then
		items[#items + 1] = futureCall(bindHaircapItem, initData, args, haircap_mesh)
	end
	
	if hair_accessory_mesh then
		items[#items + 1] = futureCall(bindHairAccessoryItem, initData, args, hair_accessory_mesh)
	end
end

-----------------------------------------------------------------------------
local function loadStrandHair(items, initData, args)
	local head_class = args.force_generic and 1 or initData.HeadClass
	local hair_id  = head_class == 0 and initData.HeadAssetId or initData.Hair
	local hair_brt = head_class == 0 and brts.starhead or brts.generichead
	local hair_style = initData.HairStyle
	local eyebrow = (head_class == 0) and hair_id or initData.Eyebrow
	local facial_hair = (head_class == 0) and hair_id or initData.FacialHairType
	
	local hair_name = string.format("strandbind_hair_%d_%d_%d", hair_id, head_class, hair_style)
	local beard_name = string.format("strandbind_facialhair_%d_%d_%d", facial_hair, head_class, hair_style)
	local eyebrow_name = string.format("strandbind_eyebrow_%d_%d_%d", eyebrow, head_class, hair_style)
	local attachment_name = string.format("strand_hair_attachment_%d_%d_%d", hair_id, head_class, hair_style)

	local allow_missing = true
	
	
	local hair = loadAsync(hair_brt, hair_name, allow_missing, initData.laneId)
	local beard = loadAsync(hair_brt, beard_name, allow_missing, initData.laneId)
	local eye_brow = loadAsync(hair_brt, eyebrow_name, allow_missing, initData.laneId)
	local attachment = loadAsync(hair_brt, attachment_name, allow_missing, initData.laneId)
	
	-- required mesh for attachment
	--local culling_name = "systems/hair/strandhaircullingmesh"
	--local culling_mesh = loadAsync(hair_brt, culling_name, false, initData.laneId)

	if hair then
		items[#items + 1] = futureCall(bindStrandHairItem, initData, args, slots.strandhair, "strand_hair", hair)
	end

	if beard then
		items[#items + 1] = futureCall(bindStrandHairItem, initData, args, slots.strandbeard, "strand_beard", beard)
	end

	if eye_brow then
		items[#items + 1] = futureCall(bindStrandHairItem, initData, args, slots.strandeyebrow, "strand_eye_brow", eye_brow)
	end

	if attachment then
		items[#items + 1] = futureCall(bindHairAccessoryItem, initData, args, attachment)
	end

	return hair, beard, eye_brow
end

-----------------------------------------------------------------------------
local function _loadWarmup(items, initData, prefix, isEquipped)
	local allow_missing = true
	
	local is_top = prefix == "top"

	local gender = initData.Gender
	local asset_id = is_top and initData.WarmupTopId or initData.WarmupBottomId
	local asset_variation = is_top and initData.WarmupTopTextureVariation or initData.WarmupBottomTextureVariation
	local asset_class = 1
	

	local mesh_name = string.format("%s_0_%d_%d_0_0_%d", prefix, asset_id, asset_class, gender)
	local asset_mesh = loadAsync(brts.wardrobe, mesh_name, allow_missing, initData.laneId)

	if not asset_mesh then return end

	local color_name = string.format("%s_%d_%d_%d_%d_color;debug_texture_color", prefix, asset_id, asset_class, asset_variation, gender)
	local normal_name = string.format("%s_%d_%d_%d_%d_normal;debug_texture_normal", prefix, asset_id, asset_class, asset_variation, gender)
	local coeff_name = string.format("%s_%d_%d_%d_%d_coeff;debug_texture_coeff", prefix, asset_id, asset_class, asset_variation, gender)
	local ao_name = string.format("%s_%d_%d_%d_%d_ambient;%s_%d_%d_ambient;wardrobe_fallback_ambient", prefix, asset_id, asset_class, asset_variation, gender, prefix, asset_id, gender)
	local taa_name = string.format("%s_%d_%d_%d_%d_taa;%s_%d_%d_taa;wardrobe_fallback_taa", prefix, asset_id, asset_class, asset_variation, gender, prefix, asset_id, gender)

	local weave_normal_name = string.format("%s_%d_%d_weave_nm_array;debug_texture_normal_array", prefix, asset_id, asset_class)
	local weave_coeff_name = string.format("%s_%d_%d_weave_coeff_array;debug_texture_normal_array", prefix, asset_id, asset_class)

	local colorMap = loadAsync(brts.wardrobe, color_name, false, initData.laneId)
	local coeffMap = loadAsync(brts.wardrobe, coeff_name, false, initData.laneId)
	local aoMap = loadAsync(brts.wardrobe, ao_name, false, initData.laneId)
	local normalMap = loadAsync(brts.wardrobe, normal_name, false, initData.laneId)
	local taaMap = SETTING.UseAnisoSpecular and loadAsync(brts.wardrobe, taa_name, false, initData.laneId) or nil

	local weaveNormalMap = loadAsync(brts.wardrobe, weave_normal_name, false, initData.laneId)
	local weaveCoeffMap = loadAsync(brts.wardrobe, weave_coeff_name, false, initData.laneId)
	
	local cullMap = loadAsync(brts.body, "nocull", false, initData.laneId)

	local hotspots_name = string.format("%s_%d_%d_%d_%d_hotspot", prefix, asset_id, asset_class, asset_variation, gender)
	local hotspot = loadAsync(brts.wardrobe, hotspots_name, allow_missing, initData.laneId)
	
	if is_top then
		local colors = {initData.TeamColorPri, initData.TeamColorSec, initData.TeamColorTer}
		local ddsCrestMap = _loadCrestForWardrobe(initData, colors[1])

		items[#items + 1] = futureCall(_bindWarmupTop, initData, asset_mesh,
			colorMap, coeffMap, aoMap, normalMap, taaMap,
			weaveCoeffMap, weaveNormalMap, cullMap, hotspot, ddsCrestMap, colors, isEquipped)
	else
		local black = {0.05, 0.05, 0.05, 0}
		local colors = {black, initData.TeamColorPri, initData.TeamColorTer}
		local ddsCrestMap = _loadCrestForWardrobe(initData, colors[1])

		items[#items + 1] = futureCall(_bindWarmupBottom, initData, asset_mesh,
			colorMap, coeffMap, aoMap, normalMap, taaMap,
			weaveCoeffMap, weaveNormalMap, cullMap, hotspot, ddsCrestMap, colors, isEquipped)
	end
end

-----------------------------------------------------------------------------
-- presentation (Fab) tracksuits variations
local TracksuitsSub = {
	weightsWarm = { 0, 20, 80, 0, 0 },
	weightsCold = { 0,  20, 80, 0, 0 },
	variations = {
		{ bib = true,  jacket = false, pants = false },
		{ bib = false, jacket = true,  pants = true  },
		{ bib = false, jacket = true,  pants = false },
		{ bib = true,  jacket = true,  pants = true  },
		{ bib = true,  jacket = true,  pants = false }
	}
}

local function _loadWarmupGear(items, initData)
	local isCold = initData.Cold ~= 0

	local weights = isCold and TracksuitsSub.weightsCold or TracksuitsSub.weightsWarm
	local rndvalue = _randomWeightedChoice(weights)
	--log("lua: random ".. rndvalue)
	local tracksuit = TracksuitsSub.variations[rndvalue]
	
	local useBib
	local useJacket
	local usePants

	local useTop = initData.UseKitWarmupTop 
	local useBottom = initData.UseKitWarmupBottom
	
	if useTop == enum.WarmupTopType_None then
		useBib = tracksuit.bib or initData.IsSwapped ~= 0
		useJacket = tracksuit.jacket
		-- todo: jacket is not compatible with bibs
		-- useJacket = tracksuit.jacket and not useBib
	elseif useTop == enum.WarmupTopType_BibOnJacket then
		useBib = true
		useJacket = true
	elseif useTop == enum.WarmupTopType_Disable then
		useBib = false
		useJacket = false
	else
		useBib = useTop == enum.WarmupTopType_Bib 
		useJacket = useTop == enum.WarmupTopType_Jacket
	end
	
	if useBottom == enum.WarmupBottomType_None then
		usePants = tracksuit.pants
	elseif useBottom == enum.WarmupBottomType_Disable then
		usePants = false
	else
		usePants = useBottom == enum.WarmupBottomType_Pants
	end

	
	-- Carson Picket (267240) special case.
	-- Missing left arm, force only bib is allowed.
	if initData.HeadAssetId == 267240 then 
		useBib = true
		useJacket = false
	end

	local gender = initData.Gender
	if useBib then
		local mesh_name = string.format("warmup_0_0_0_%d", gender)
		local mesh = loadAsync(brts.body, mesh_name, false, initData.laneId)

		local bib_id = initData.HasCustomBib ~= 0 and initData.TournamentId or 0
		local color_name = string.format("warmup_top_0_%d_%d_color;warmup_top_0_0_color", bib_id, initData.TeamSide)
		local colorMap = loadAsync(brts.body, color_name, false, initData.laneId)
		items[#items + 1] = futureCall(_bindWarmupBib, initData, mesh, colorMap)
	end
	useTop = enum.WarmupTopType_Jacket
	initData.UseJacketInIntro = true

	if (usePants or SETTING.LoadAllWarmupItems or initData.UsePantsInIntro ~= 0) and useBottom ~= enum.WarmupBottomType_Disable then
		local side
		local kit_type1 = initData.KitType
		if initData.IsGoalie ~= 1 then

			if kit_type1 == 1 then
				side = "away"
			elseif kit_type1 == 0 then
				side = "home"
			else
				side = "alternative"
			end
			initData.WarmupBottomId = getAnthemPantsId(initData.TeamId, side, initData.WarmupBottomId)
			initData.WarmupBottomTextureVariation = getAnthemPantsTextureVariation(initData.TeamId, side, initData.WarmupBottomTextureVariation)
			_loadWarmup(items, initData, "bottom", usePants)
		end
	end

	if (useJacket or SETTING.LoadAllWarmupItems or initData.UseJacketInIntro ~= 0) and useTop ~= enum.WarmupTopType_Disable then
			local side
			local kit_type1 = initData.KitType
			if initData.IsGoalie ~= 1 then
	
				if kit_type1 == 1 then
					side = "away"
				elseif kit_type1 == 0 then
					side = "home"
				else
					side = "alternative"
				end
	
			initData.WarmupTopId = getAnthemJacketId(initData.TeamId, side, initData.WarmupTopId)
			initData.WarmupTopTextureVariation = getAnthemJacketTextureVariation(initData.TeamId, side, initData.WarmupTopTextureVariation)
		_loadWarmup(items, initData, "top", useJacket)
			end
	end
end

-----------------------------------------------------------------------------
local function loadAccessory(items, initData, args, idx, accessory)
	if idx < 1 and idx > #accessory_slots then return end

	local gender = initData.Gender
	local model = accessory.AccessoryModel
	local variation = accessory.AccessoryVariation
	local tournamentid = initData.TournamentId
	local loadsleeves = (initData.ArmLength == 0)
	local nogkgloves = (initData.IsGoalie == 0 and initData.UseKitGkGloves == 0) or initData.GkGloveType==-1

	if model == 0 then return end -- early out if no accessory
	if initData.UseKitAccessory == 0 and initData.UseWardrobeAccessory == 0 then return end
	
	if model <= 100 then -- player and referee accessories have different naming
		if model == gloveid then
			if nogkgloves then -- Disable loading gloves if we are goalkeeper, to avoid clipping gkgloves
				local accessorycolorid = accessory.AccessoryColor
				local mesh_name = string.format("glove_%d_%d", accessorycolorid, gender)
				local mesh = loadAsync(brts.accessory, mesh_name, true, initData.laneId)
				if mesh then
					local colorMap = loadAsync(brts.accessory, string.format("glove_%d_color", accessorycolorid), false, initData.laneId)
					local normalMap = loadAsync(brts.accessory, string.format("glove_%d_normal", accessorycolorid), false, initData.laneId)
					local coeffMap = loadAsync(brts.accessory, string.format("glove_%d_coeff", accessorycolorid), false, initData.laneId)
					items[#items + 1] = futureCall(_bindAccessory, initData, args, idx, accessory, mesh, colorMap, normalMap, coeffMap, nil, nil, nil, "gloves")
				end
			end
		elseif (model == sleevesid)  and loadsleeves then
			-- variation = side
			local accessorycolorid = accessory.AccessoryColor
			local mesh_name = string.format("sleeve_%d_%d_%d", accessorycolorid, variation, gender)
			local mesh = loadAsync(brts.accessory, mesh_name, true, initData.laneId)
			if mesh then
				local colorMap = loadAsync(brts.accessory, string.format("sleeve_%d_%d_color", accessorycolorid, variation), false, initData.laneId)
				local coeffMap = loadAsync(brts.accessory, string.format("sleeve_%d_%d_coeff", accessorycolorid, variation), false, initData.laneId)
				local normalMap = loadAsync(brts.accessory, string.format("sleeve_%d_%d_normal", accessorycolorid, variation), false, initData.laneId)
				items[#items + 1] = futureCall(_bindAccessory, initData, args, idx, accessory, mesh, colorMap, normalMap, coeffMap, nil, nil, nil, "sleeve")
			end
		else
			local mesh_name = string.format("accessory_%d_%d_%d", model, variation, gender)
			local mesh = loadAsync(brts.accessory, mesh_name, true, initData.laneId)
			if mesh then
				local colorMap = loadAsync(brts.accessory, string.format("accessory_%d_color", model), false, initData.laneId)
				local normalMap = loadAsync(brts.accessory, string.format("accessory_%d_normal", model), false, initData.laneId)
				local coeffMap = loadAsync(brts.accessory, string.format("accessory_%d_coeff", model), false, initData.laneId)
				items[#items + 1] = futureCall(_bindAccessory, initData, args, idx, accessory, mesh, colorMap, normalMap, coeffMap, nil, nil, nil, nil)
			end
		end
	else
		local accessory_side = 0
		local mesh_name = string.format("accessory_%d_0_%d_%d", model, accessory_side, gender)
		local mesh = loadAsync(brts.accessory, mesh_name, true, initData.laneId)
		if mesh then
			
			-- if tournament id is 0, set the regular variation
			local supports_event_clothing = (model >= 800 and model < 900)
			tournamentid = (tournamentid > 0 and supports_event_clothing) and tournamentid or variation

			-- some accessories don't have aomap so fallback to debug_texture_aoblend
			local ao_name = string.format("accessory_%d_%d_0_0_ambient;accessory_%d_%d_0_0_ambient;debug_texture_aoblend", model, tournamentid, model, variation)
			local color_name = string.format("accessory_%d_%d_0_0_color;accessory_%d_%d_0_0_color", model, tournamentid, model, variation)
			local normal_name = string.format("accessory_%d_%d_0_0_normal;accessory_%d_%d_0_0_normal", model, tournamentid, model, variation)
			local coeff_name = string.format("accessory_%d_%d_0_0_coeff;accessory_%d_%d_0_0_coeff", model, tournamentid, model, variation)

			local aoMap = loadAsync(brts.accessory, ao_name, false, initData.laneId)
			local colorMap = loadAsync(brts.accessory, color_name, false, initData.laneId)
			local normalMap = loadAsync(brts.accessory, normal_name, false, initData.laneId)
			local coeffMap = loadAsync(brts.accessory, coeff_name, false, initData.laneId)

			-- it has to be moved into some common folder in proper brt
			local weave_normal_name = string.format("accessory_%d_weave_nm_array;clothing_weave_nm_array", model)
			local weave_coeff_name = string.format("accessory_%d_weave_coeff_array;clothing_weave_coeff_array", model)
			local weaveNormalMap = loadAsync(brts.accessory, weave_normal_name, true, initData.laneId)
			local weaveCoeffMap = loadAsync(brts.accessory, weave_coeff_name, true, initData.laneId)

			items[#items + 1] = futureCall(_bindAccessory, initData, args, idx, accessory, mesh, colorMap, normalMap, coeffMap,
				aoMap, weaveNormalMap, weaveCoeffMap, nil)
		end
	end
end


-----------------------------------------------------------------------------
local function loadRefAccessory(items, laneId, tag, model, variation, gender)
	local mesh_name = string.format("accessory_%d_%d_%d", model, variation, gender)
	local mesh = loadAsync(brts.accessory, mesh_name, true, laneId)
	if mesh then
		local colorMap = loadAsync(brts.accessory, string.format("accessory_%d_color", model), false, laneId)
		local normalMap = loadAsync(brts.accessory, string.format("accessory_%d_normal", model), false, laneId)
		local coeffMap = loadAsync(brts.accessory, string.format("accessory_%d_coeff", model), false, laneId)
		items[#items + 1] = futureCall(buildRefAccessory, laneId, tag, mesh, colorMap, normalMap, coeffMap)
	end
end

-----------------------------------------------------------------------------
local function loadPlayerBeard(items, initData, args)
	local isCreatedPlayer = initData.IsCreatedPlayer ~= 0
	-- load 3d beard for generics
	local isGeneric = initData.HeadClass ~= 0
	--if not isCreatedPlayer or initData.FacialHairType < 1 then 
	if (not isCreatedPlayer and not isGeneric) or initData.FacialHairType < 1 then 
		return false 
	end

	local allow_missing = true
	local model = initData.FacialHairType
	local headclass = 1 -- always generic 
	local variation = 0 -- no variation / hairstyle

	local hair_name = string.format("facialhair_%d_%d_%d", model, headclass, variation)
	local haircap_name = string.format("facialhaircap_%d_%d_%d", model, headclass, variation)

	local mesh_hair = loadAsync(brts.generichead, hair_name, allow_missing, initData.laneId)
	local mesh_cap = loadAsync(brts.generichead, haircap_name, allow_missing, initData.laneId)

	if mesh_hair then
		local colorMap = loadAsync(brts.generichead, string.format("facialhair_%d_%d_%d_color", model, headclass, variation), false, initData.laneId)
		local coeffMap = loadAsync(brts.generichead, string.format("facialhair_%d_%d_%d_coeff", model, headclass, variation), false, initData.laneId)

		items[#items + 1] = futureCall(bindPlayerBeard, initData, args, false, mesh_hair, colorMap, coeffMap)

		if mesh_cap then
			items[#items + 1] = futureCall(bindPlayerBeard, initData, args, true, mesh_cap, colorMap, coeffMap)
		end
	end
	
	return mesh_hair
end

-----------------------------------------------------------------------------
local function loadShadow(items, initData)
	local jersey_sleeve_length = initData.JerseySleeveLength
	local shadow_name = string.format("playershadow_5_%d_0", jersey_sleeve_length)
	local importance_name = string.format("playerimportance_5_%d_0", jersey_sleeve_length)

	local shadow_mesh = loadAsync(brts.body, shadow_name, false, initData.laneId)
	local importance_mesh = loadAsync(brts.body, importance_name, false, initData.laneId)

	items[#items + 1] = futureCall(bindShadowItem, initData, shadow_mesh, importance_mesh)
end



-----------------------------------------------------------------------------
-- detect errors when reading an absent field in table
-- lua's behaviour is to return nil
local function _no_read_access(t, k)
	error("error: invalid read, no key in the table: " .. k)
	return nil
end

local function _disable_read_from_undefined_key(t, disable)
	local mt = getmetatable(t) or {}
	if disable then
		mt.__index = _no_read_access
	else
		mt.__index = rawget(t, k)
	end
	setmetatable(t, mt)
end

function _print_global()
	log("[lua] _G contents start:")
	for n in pairs(_G) do log(n) end
	log("[lua] _G contents end")
end
-----------------------------------------------------------------------------
local function _loadPsdAssets(assets, initData, args)
	if args.use_psd == false or args.use_gpucompute == false then return end

	local _hasAccessory = function(initData)
		if initData.IsGoalie ~= 0 then return true end
		for _, accessory in ipairs(initData.Accessories) do
			local accessory_model = accessory.AccessoryModel
			-- if accessory_model == 16 then return true end -- winter gloves
			-- if accessory_model ==  6 or accessory_model ==  7 then return true end -- wrist athletic tape
			-- if accessory_model == 22 or accessory_model == 23 then return true end -- finger tape
			-- if accessory_model == 200 then return true end -- gloves

			if accessory_model ~= 0 then return true end
		end
		return false
	end

	local gender = initData.Gender
	local official = initData.OfficialType

	do -- head
		-- psd face backets, if create player then use mouth shape mapping
		-- cranium, backeting is computed in runtime and loaded as static asset from collection
		-- todo: do we still rely on FacePoserPreset from DB for generics?
		local facePsdLayer0 = initData.FacePsdLayer0
		local facePsdLayer1 = initData.FacePsdLayer1

		-- Head has a custom PSD
		local head_psd_name = string.format("head_%d_%d_%d_psd", initData.Head, initData.HeadClass, initData.HeadVariation)
		local head_psd = loadAsync(brts.psd, head_psd_name, true, initData.laneId)

		if head_psd then
			assets.PsdFaceUpper = nil
			assets.PsdFaceLower = head_psd
		else
			local head_psd_lower_name = string.format("head_common_%d_%d_0_psd;head_common_%d_0_0_psd", gender, facePsdLayer0, gender)
			local head_psd_upper_name = string.format("head_common_%d_%d_1_psd;head_common_%d_0_1_psd", gender, facePsdLayer1, gender)
			assets.PsdFaceUpper = loadAsync(brts.psd, head_psd_upper_name, false, initData.laneId)
			assets.PsdFaceLower = loadAsync(brts.psd, head_psd_lower_name, false, initData.laneId)
		end
		
		local head_secondary_control_psd_name = "head_common_secondary_0_psd"
		assets.PsdFaceSecControl = loadAsync(brts.psd, head_secondary_control_psd_name, false, initData.laneId)

		-- head psd array for generic and created players
		if initData.HeadClass ~= 0 then
			local head_psd_array_lower_name = string.format("head_psd_array_%d_0", gender)
			local head_psd_array_upper_name = string.format("head_psd_array_%d_1", gender)
			assets.HeadPsdArrayLower = loadAsync(brts.psd, head_psd_array_lower_name, false, initData.laneId)
			assets.HeadPsdArrayUpper = loadAsync(brts.psd, head_psd_array_upper_name, false, initData.laneId)
		end

		-- psd head mask
		local jerseyCollarType = initData.JerseyCollarType
		local head_psd_mask = ""
		if jerseyCollarType >= 0 and jerseyCollarType < #PSD_HEAD_MASKING then
			if initData.UnderArms == -1 and initData.UnderNeck == -1 then
				head_psd_mask = PSD_HEAD_MASKING[jerseyCollarType + 1]
			else
				head_psd_mask = "MidHigh"
			end
		end
		local mask_psd_name = string.format("psdMT_Collar%s;psdMT_Collar", head_psd_mask)
		assets.MaskTuningPsd = loadAsync(brts.psd, mask_psd_name, false, initData.laneId)
	end

	---------------------------------------------------------
	do -- upperbody
		local skipArmPsd = (official == enum.OfficialType_Manager) or (official == enum.OfficialType_None and _hasAccessory(initData))
		if not skipArmPsd and (SETTING.UseFullBody) and (SETTING.UseBodyPSD) then 
			--[[
			local body_name = 
					--string.format("bodyupper_%d_psd", gender)
					string.format("bodyupper_%d_0_1_psd", gender)
			local arms_name = string.format("bodyupper_%d_1_1_psd", gender)

			assets.PsdBodyUpperMain = loadAsync(brts.psd, body_name, true, initData.laneId)
			assets.PsdBodyUpperArms = loadAsync(brts.psd, arms_name, true, initData.laneId)
			]]--
			local body_name = string.format("bodyupper_%d_psd", gender)
			assets.PsdBodyUpperMain = loadAsync(brts.psd, body_name, true, initData.laneId)
			assets.PsdBodyUpperArms = nil
		end
	end

	---------------------------------------------------------
	do -- legs
		if SETTING.UseBodyPSD then
			-- yury todo: why do we load leg psd for managers and avatar, long pants? 
			-- local leg_psd_name = string.format("legs_%d_%d_psd", initData.SockLength, gender)
			local leg_psd_name = string.format("bodylower_%d_psd", gender)
			assets.PsdLeg = loadAsync(brts.psd, leg_psd_name, true, initData.laneId)
		end
	end

	---------------------------------------------------------
	-- TODO remove from code
	-- mask for recalculating normals for face PSD
	-- assets.HeadNormalCalcMask = loadAsync(brts.base, "head_mask_meshcompute", false, initData.laneId)

	-- load welding when using top outfit
	if initData.UseWardrobeTopBase ~= 0 then 
		if initData.HeadClass == 0 then
			local head_welding = string.format("head_%d_%d_%d_bodyupper_%d_weld;basehead_%d_bodyupper_%d_weld", 
				initData.Head, initData.HeadClass, initData.HeadVariation, gender, 
				gender, gender)
			assets.GpuDeformWeldingAsset = loadAsync(brts.psd, head_welding, false, initData.laneId)
		else
			local head_welding = string.format("basehead_%d_bodyupper_%d_weld", gender, gender)
			assets.GpuDeformWeldingAsset = loadAsync(brts.psd, head_welding, false, initData.laneId)
		end
	end
end
-----------------------------------------------------------------------------
local function _loadRigamateAssets(assets, initData)
	local gender = initData.Gender
	local rigamate_type = initData.RigamateType

	local lod0 = 0 
	local lod1 = 1

	-- use cheaper body rigamate on NX
	if IS_MOBILE then 
		lod0, lod1 = 2, -1 
	end

	-- FB rigamate expressions
	local body0_asset_name = string.format("rigamate_expr_asset_body_%d_%d_%d", rigamate_type, lod0, gender)
	local body1_asset_name = string.format("rigamate_expr_asset_body_%d_%d_%d", rigamate_type, lod1, gender)
	--local body2_asset_name = string.format("rigamate_expr_asset_body_%d_2_%d", rigamate_type, gender)

	assets.BodyLod0Asset = loadAsync(brts.rigamate, body0_asset_name, false, initData.laneId)
	if lod1 >= 0 then
		assets.BodyLod1Asset = loadAsync(brts.rigamate, body1_asset_name, false, initData.laneId)
	end
	--assets.BodyLod2Asset = loadAsync(brts.rigamate, body2_asset_name, false, initData.laneId) -- not being used 

	assets.FaceAsset = loadAsync(brts.rigamate, "rigamate_expr_facerig_0", false, initData.laneId)
	assets.FaceWrinkleAsset = loadAsync(brts.rigamate, "rigamate_expr_asset_face_wrinkle", false, initData.laneId)
	assets.JerseyWrinkleAsset = loadAsync(brts.rigamate, "rigamate_expr_asset_jersey_wrinkle", false, initData.laneId)
	assets.EyesAsset = loadAsync(brts.rigamate, "rigamate_expr_asset_face_eyes", false, initData.laneId)
	assets.GpJiggleExtractAsset = loadAsync(brts.rigamate, "rigamate_expr_asset_gp_jiggle_extract", false, initData.laneId)
	assets.GpJiggleApplyAsset = loadAsync(brts.rigamate, "rigamate_expr_asset_gp_jiggle_apply", false, initData.laneId)
end

-----------------------------------------------------------------------------
local function _loadClothColliders(assets, initData)
	local gender = initData.Gender
	-- cloth external colliders
	local collider_top_name = string.format("collider_0_%d_%d", initData.TopColliderId, gender)
	local collider_bottrom_name = string.format("collider_1_%d_%d", initData.BottomColliderId, gender)
	assets.TopCollider = loadAsync(brts.body, collider_top_name, true, initData.laneId)
	assets.BottomCollider = loadAsync(brts.body, collider_bottrom_name, true, initData.laneId)
	if SETTING.UseHandColliders then
		assets.HandCollider = loadAsync(brts.body, string.format("collider_0_50_%d", gender), true, initData.laneId)
	end
end

-----------------------------------------------------------------------------
local function _isStrandHair(initData)
	-- disable hair on generic heads for Xbox Series S, due memory shortage
	local isGeneric = initData.HeadClass ~= 0
	local isCreatedPlayer = initData.IsCreatedPlayer ~= 0
	-- do not load generic SBH for LOCKHART 
	local _xbss = (PlatformMode == 'SCARLETT_LOCKHART' and isGeneric) 

	-- for team sheet overlays strandhair should be disabled from loading
	-- can't afford memory and performance spikes
	return (SETTING.EnableStrandHair
		and initData.DisableStrandHair == 0 
		and initData.DisableCloth == 0
		and not _xbss
		and strandEnabled
		) 
end

-----------------------------------------------------------------------------
-- FifaPlayer = {}
-- FifaPlayer.LoadShorts = function(items, generatedTextures, initData)

-- player scheme
	--+ jersey
	--+ short and gkpants
	--+ under gear
		--+ under arm
		--+ under neck
		--+ under shorts
	--+ shoes
	--+ socks
	--+ top wardrobe
		--+ layer 0
		--+ layer 1
	--+ bottom wardrobe
		--+ layer 0
		--+ layer 1
	--+ team crest
	--+ bodyupper
	--+ bodylower
	--+ character shadow
	--
	--+ accessories
		--+ gloves
		--+ other
		--+ referee accessories
	--+ warmupgear: bibs
--
-- dont forget to set setIncludeCullTagHashes and setTagHashes
-- initData doesn't contain booleans, they are converted to int

function player.loadPlayerKit(initData)
	_disable_read_from_undefined_key(initData, true)

	local items = {}
	local generatedTextures = {}
	local assets = {}

	-- runtime overrides 
	local args = {
		use_psd = _usePsd(initData),
		use_gpucompute = (_isChild(initData) == false), -- don't use gpu compute for children
		use_strandhair = _isStrandHair(initData),
		use_warpcloth = (_isChild(initData) == false), -- don't use warpcloth for children, they have female body

		stamp_beard = true,

		static_jersey = false,
		static_shorts = false,
		static_socks = false,
		disable_eyelashes = false,
		force_generic = false
	}

	if gIsRendererEnabled then
		-- don't use warpcloth if any item is wardrobe
		args.use_warpcloth = args.use_warpcloth and initData.UseWardrobeTopBase == 0 and initData.UseWardrobeTopSecondLayer == 0
		args.use_warpcloth = args.use_warpcloth and initData.UseWardrobeBottom == 0 and initData.UseWardrobeBottomSecondLayer == 0	

		-- hotspots
		local hotspotAsset, competitionHotspot = loadHotspots(initData)

		-- schedule texture generation first

		-- team kit 
		loadKitJersey(items, generatedTextures, initData, args, hotspotAsset, competitionHotspot, assets)
		loadKitShorts(items, initData, args, hotspotAsset)
		
		-- body
		loadUpperBody(items, generatedTextures, initData, args, assets)
		loadLowerBody(items, generatedTextures, initData, args, assets)

		-- head
		-- need to load before hair and beard to prevent wrap deform delay of one frame
		loadHead(items, generatedTextures, initData, args, assets)

		-- 3d beard
		local beard_3d = loadPlayerBeard(items, initData, args)
		args.stamp_beard = true --(beard_3d == nil) -- We always want to stamp

		-- hair
		-- for strand hair load card hair too 
		if args.use_strandhair then
			local _, strand_beard = loadStrandHair(items, initData, args)
			loadHair(items, initData, args)
			
			args.stamp_beard = args.stamp_beard or strand_beard
		else
			loadHair(items, initData, args)
		end

		-- wardrobe outfit
		loadTop0(items, initData)
		loadTop1(items, initData)
		loadBottom0(items, initData)
		loadBottom1(items, initData)

		-- shoes and socks
		loadShoes(items, initData)
		loadSocks(items, generatedTextures, initData, args, hotspotAsset, assets)

		-- goalkeeper gloves
		loadGkGloves(items, initData)

		local official = initData.OfficialType
		-- warmup gear: only for players
		if official == enum.OfficialType_None then
			_loadWarmupGear(items, initData)
		end

		-- accessory
		for idx, accessory in ipairs(initData.Accessories) do
			loadAccessory(items, initData, args, idx, accessory)
		end
		
		-- ref accessories
		do
			local gender = initData.Gender
			local laneId = initData.laneId

			if official == enum.OfficialType_Referee then
				for _, v in ipairs(ref_accessories) do
					loadRefAccessory(items, laneId, v.slot, v.model, v.side, gender)
				end
			elseif official == enum.OfficialType_Linesman or official == enum.OfficialType_Fourth then
				loadRefAccessory(items, laneId, "ref_watch_left", 4, 0, gender)
				loadRefAccessory(items, laneId, "ref_earpiece_left", 2, 0, gender)
				loadRefAccessory(items, laneId, "ref_gltwatch_right", 20, 1, gender)
			end
			
		end

		-- shadows
		loadShadow(items, initData)
	end

	-- load non-appearance assets for external usage
	_loadPsdAssets(assets, initData, args)
	_loadRigamateAssets(assets, initData)
	_loadClothColliders(assets, initData)

	--log(string.format("[lua] pload %d, %s, %d items, %d gen textures", initData.PlayerId, initData.KitName, #items, #generatedTextures))
	--_print_global()
	--collectgarbage('collect')

	return items, generatedTextures, assets
end

-----------------------------------------------------------------------------
function _disableUnderGear(initData)
	-- By design we agreed to not overwrite initData from this file.
	-- Use player.lua instead.

	--initData.JerseySleeveLength = 0
	--initData.ArmLength = 0
	--initData.UnderArms = -1
	--initData.UnderNeck = -1
	--initData.UnderShorts = -1
end

function player.loadStaticJersey(initData)
	_disable_read_from_undefined_key(initData, true)

	-- runtime overrides 
	local args = {
		use_warpcloth = false,
		static_jersey = true,
	}
	-- _disableUnderGear(initData)

	-- variables
	local items = {}
	local generatedTextures = {}

	-- hotspots
	local hotspotAsset, competitionHotspot = loadHotspots(initData)

	-- load mesh
	local jersey_name = string.format("static_jersey_%d", initData.StaticJerseyVariation)
	local jersey_mesh = loadAsync(brts.worlds_clothing, jersey_name, false, initData.laneId)

	-- load kit 
	loadKitJersey(items, generatedTextures, initData, args, hotspotAsset, competitionHotspot, assets, nil, jersey_mesh)

	-- jobs done, return result
	return items, generatedTextures
end

function player.loadStaticShorts(initData)
	_disable_read_from_undefined_key(initData, true)

	-- runtime overrides 
	local args = {
		use_warpcloth = false,
		static_shorts = true,
	}
	-- _disableUnderGear(initData)

	-- variables
	local items = {}
	local generatedTextures = {}
	local assets = {}

	-- hotspots
	local hotspotAsset, competitionHotspot = loadHotspots(initData)

	-- load mesh
	local shorts_name = string.format("static_Shorts_%d", initData.StaticShortsVariation)
	local shorts_mesh = loadAsync(brts.worlds_clothing, shorts_name, false, initData.laneId)

	-- load kit
	loadKitShorts(items, initData, args, hotspotAsset, shorts_mesh)

	-- jobs done, return result
	return items, generatedTextures
end

function player.loadStaticSocks(initData)
	_disable_read_from_undefined_key(initData, true)

	-- runtime overrides 
	local args = {
		static_socks = true,
	}

	-- variables
	local items = {}
	local generatedTextures = {}
	local assets = {}

	-- hotspots
	local hotspotAsset, competitionHotspot = loadHotspots(initData)

	-- load kit
	loadSocks(items, generatedTextures, initData, args, hotspotAsset, assets)

	-- jobs done, return result
	return items, generatedTextures
end

-----------------------------------------------------------------------------
function player.loadJersey(initData)
	_disable_read_from_undefined_key(initData, true)

	local items = {}
	local generatedTextures = {}

	if gIsRendererEnabled then
		-- runtime overrides 
		local args = {
			use_warpcloth = false,
			static_jersey = false,
		}

		-- hotspots
		local hotspotAsset, competitionHotspot = loadHotspots(initData)

		-- team kit 
		loadKitJersey(items, generatedTextures, initData, args, hotspotAsset, competitionHotspot, assets)
	end

	return items, generatedTextures
end

-----------------------------------------------------------------------------
-- Low res crowd jersey loading and compositing

local function compositeLowResCrowdJersey(initData, colorMap, brandMap, crestMap, hotspotAsset, isCustomKit)
	local full_hs = { Bounds = {0, 0, 1.0, 1.0}, Rotation = 0 }
	local crest_hotspot = getHotspotEntry(hotspotAsset, "jersey", "team")
	local brand_hotspot = getHotspotEntry(hotspotAsset, "jersey", "brand")

	local desc = LowResCrowdJerseyCompositorDesc
	local mips, compress, alpha = 0, true, 1.0

	local cryoResourceMap = createCryoTextureResourceMap()
	cryoResourceMap:addTexture(colorMap, "colorMap")
	cryoResourceMap:addTexture(brandMap, "brandMap")
	cryoResourceMap:addTexture(crestMap, "crestMap")

	local cryoRecipe = createCryoTextureRecipe()
	local cryoLayer = cryoRecipe:addTextureLayer(nil, "colorMap")
	cryoLayer:setBlending(enum.CryoBlendMode_Disabled)

	if initData.isCustomKit ~= 1 then
		cryoLayer = cryoRecipe:addTextureLayer(nil, "brandMap")
		cryoLayer:setLegacyPlacement(brand_hotspot.Bounds, brand_hotspot.Rotation)

		cryoLayer = cryoRecipe:addTextureLayer(nil, "crestMap")
		cryoLayer:setLegacyPlacement(crest_hotspot.Bounds, crest_hotspot.Rotation)
	end

	local cryoCompositor = createCryoTextureCompositor("LowResCrowdJersey", 0, desc.width, desc.height, mips, compress, desc.format, initData.laneId)
	return cryoCompositor:composite(cryoResourceMap, cryoRecipe)
end

function player.loadLowResCrowd(initData)
	_disable_read_from_undefined_key(initData, true)

	local result = {}
	
	local allow_missing = true

	-- initData type is FifaAssetInitData.ddf/class FifaLowResCrowdInitData
	-- result type is FifaLuaResultData.ddf/class FifaLuaOutLRCData
	
	-- In ddf these are bools, but they are translated to int for lua
	local enableAlternateKits = initData.EnableAlternateKits == 1

	local initDataSets = 
	{
		{
			outputPrefix 	= "Home",
			kitId 			= initData.HomeTeamId,
			kitType 		= initData.HomeKitType,
			kitYear 		= initData.HomeKitYear,
			facepaintId		= initData.HomeTeamId,
			facepaintType0	= initData.HomeFacepaintType0,
			facepaintType1	= initData.HomeFacepaintType1,
			facepaintType2	= initData.HomeFacepaintType2,
			isCustomKit		= initData.IsHomeCustomKit
		},
		{
			outputPrefix 	= "Away",
			kitId 			= initData.AwayTeamId,
			kitType 		= initData.AwayKitType,
			kitYear 		= initData.AwayKitYear,
			facepaintId		= initData.AwayTeamId,
			facepaintType0	= initData.AwayFacepaintType0,
			facepaintType1	= initData.AwayFacepaintType1,
			facepaintType2	= initData.AwayFacepaintType2,
			isCustomKit		= initData.IsAwayCustomKit
		}
	}
		
	for _, data in ipairs(initDataSets) do
		-----------------------
		-- kits
		-----------------------
		local kitData = {laneId = initData.laneId, CrestAssetId = -1, Kit = data.kitId, KitType = data.kitType, KitYear = data.kitYear, isCustomKit = data.isCustomKit}
		-- hotspots
		local hotspotAsset, competitionHotspot = loadHotspots(kitData)
		-- texture maps
		local color_name = nil
		if enableAlternateKits and not ((kitData.KitType % 4) == 0) then
			if kitData.KitType >= 40 then
				color_name = string.format("jersey_%d_%d_%d_color;jersey_0_0_0_color", kitData.Kit, 40, kitData.KitYear)
			else
				color_name = string.format("jersey_%d_%d_%d_color;jersey_0_0_0_color", kitData.Kit, 0, kitData.KitYear)
			end
		else
			color_name = string.format("jersey_%d_%d_%d_color;jersey_0_0_0_color", kitData.Kit, kitData.KitType, kitData.KitYear)
		end
		local colorMap = loadAsync(brts.kit, color_name, false, initData.laneId)
		local coeffMap = nil
		if SETTING.EnableLRCCoeffMaps then
			local coeff_name = string.format("jersey_%d_%d_%d_coeff;jersey_0_0_0_coeff", kitData.Kit, kitData.KitType, kitData.KitYear)
			coeffMap = loadAsync(brts.kit, coeff_name, false, initData.laneId)
		end
		if SETTING.EnableLRCJerseyCompositor then
			local crestColorMap, crestCoeffMap, crestNormalMap = _loadTeamCrest(kitData, "crest")
			local brandColorMap, brandCoeffMap, brandNormalMap = _loadBrandMaps(kitData, "brand_jersey")	
			local colorGeneratedMap = futureCall(compositeLowResCrowdJersey, kitData, colorMap, brandColorMap, crestColorMap, hotspotAsset)
			result[data.outputPrefix .. "JerseyColor0Composited"] = colorGeneratedMap
			result[data.outputPrefix .. "JerseyColor1Composited"] = colorGeneratedMap
			if SETTING.EnableLRCCoeffMaps then
				local coeffGeneratedMap = futureCall(compositeLowResCrowdJersey, kitData, coeffMap, brandCoeffMap, crestCoeffMap, hotspotAsset)
				result[data.outputPrefix .. "JerseyCoeff0Composited"] = coeffGeneratedMap
				result[data.outputPrefix .. "JerseyCoeff1Composited"] = coeffGeneratedMap
			end
		else
			result[data.outputPrefix .. "JerseyColor0"] = colorMap
			result[data.outputPrefix .. "JerseyColor1"] = colorMap
			if SETTING.EnableLRCCoeffMaps then
				result[data.outputPrefix .. "JerseyCoeff0"] = coeffMap
				result[data.outputPrefix .. "JerseyCoeff1"] = coeffMap
			end
		end

		-- load secondary kit textures if requested
		if enableAlternateKits then
			local altKitData = kitData

			local colorMap = nil
			local loc2Kit = kitData.KitType >= 40
			-- not all teams have all 4 kits so look for a KitType that exists. Valid values are [0,1,3] or [40,41,43]. [2,42] = goalie. [5] = referee
			-- this loop's last iteration will arrive back at kidData.KitType if the first 3 iterations didn't find a valid colorMap

			for i = 0, 3 do
				altKitData.KitType = (kitData.KitType + i) % 4
				if altKitData.KitType == 2 then
					altKitData.KitType = 3
				end
				if loc2Kit then
					altKitData.KitType = altKitData.KitType + 40
				end

				local color_name = string.format("jersey_%d_%d_%d_color", altKitData.Kit, altKitData.KitType, altKitData.KitYear)
				--log("[lua] trying alternate kit "..color_name)
				colorMap = loadAsync(brts.kit, color_name, allow_missing, initData.laneId)
				if colorMap then
					break
				end
			end

			-- no alternate kits found, fall back to default
			if colorMap == nil then
				altKitData.KitType = 0
				colorMap = loadAsync(brts.kit, "jersey_0_0_0_color", false, initData.laneId)
			end
			
			-- hotspots
			local hotspotAsset, competitionHotspot = loadHotspots(altKitData)
			-- texture maps
			local coeffMap = nil
			if SETTING.EnableLRCCoeffMaps then
				local coeff_name = string.format("jersey_%d_%d_%d_coeff;jersey_%d_%d_%d_coeff;jersey_0_0_0_coeff", altKitData.Kit, altKitData.KitType, altKitData.KitYear, kitData.Kit, kitData.KitType, kitData.KitYear)
				coeffMap = loadAsync(brts.kit, coeff_name, false, initData.laneId)
			end
			if SETTING.EnableLRCJerseyCompositor then
				local crestColorMap, crestCoeffMap, crestNormalMap = _loadTeamCrest(altKitData, "crest")
				local brandColorMap, brandCoeffMap, brandNormalMap = _loadBrandMaps(altKitData, "brand_jersey")	
				local colorGeneratedMap = futureCall(compositeLowResCrowdJersey, altKitData, colorMap, brandColorMap, crestColorMap, hotspotAsset)
				result[data.outputPrefix .. "JerseyColor1Composited"] = colorGeneratedMap
				if SETTING.EnableLRCCoeffMaps then
					local coeffGeneratedMap = futureCall(compositeLowResCrowdJersey, altKitData, coeffMap, brandCoeffMap, crestCoeffMap, hotspotAsset)
					result[data.outputPrefix .. "JerseyCoeff1Composited"] = coeffGeneratedMap
				end
			else
				result[data.outputPrefix .. "JerseyColor1"] = colorMap
				if SETTING.EnableLRCCoeffMaps then
					result[data.outputPrefix .. "JerseyCoeff1"] = coeffMap
				end
			end
		end

		-----------------------
		-- facepaint
		-----------------------
		if SETTING.EnableLRCFacepaint then
			for i = 0, 2 do
				local facepaint_color_name = string.format("crowdhigh_facepaint_%d_%d_color;crowdhigh_facepaint_0_0_color", data.facepaintId, data["facepaintType" .. i])
				local facepaintColorMap = loadAsync(brts.crowd_highres, facepaint_color_name, allow_missing, initData.laneId)
				result[data.outputPrefix .. "FacepaintColor" .. i] = facepaintColorMap
			end
		end
	end

	return nil, nil, result
end
-----------------------------------------------------------------------------
-- initData is FifaCrowdFanInitData
-- FifaAssetData\Shared\FifaAssetInitData.ddf
local function _bindHighResFanBody(initData, mesh, color_map, color_generated_map, dirt_map)
	local isCreatedPlayer = initData.IsCreatedPlayer ~= 0
	
	local item = createItem("crowdfan", slots.crowdfan, initData.laneId)
	item:addMeshLodPair(lod0, mesh, updateBoundingBox, playerDrawOrder, playerDrawSubOrder_Clothes)

	local outfit_mat = item:addMaterial("crowd_lod0_mat")
	local body_mat = item:addMaterial("body_mat")

	body_mat:addTexture(ShaderParam.dirtMapArrayTexture, dirt_map)

	if color_generated_map then

		outfit_mat:addGenTexture(ShaderParam.colorTexture, color_generated_map)

		body_mat:addGenTexture(ShaderParam.colorTexture, color_generated_map)	
	else

		outfit_mat:addTexture(ShaderParam.colorTexture, color_map)

		body_mat:addTexture(ShaderParam.colorTexture, color_map)
	end

	return item
end

local function _bindHighResFanProp(initData, mesh, colorMap, normalMap, coeffMap, model, slot_idx)
	local name = string.format("crowdfan_prop_%d", model)
	local item = createItem(name, crowdfan_prop_slots[slot_idx], initData.laneId)
	item:setIncludeCullTagHashes(string.format("PropSlot%d", slot_idx))
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder_Accessory)
	item:setIsActive(false) -- props disabled by default

	local mat = item:addMaterial("accessory_mat")

	mat:addTexture(ShaderParam.colorTexture, colorMap)

	mat:addTexture(ShaderParam.normalTexture, normalMap)

	mat:addTexture(ShaderParam.coefficientTexture, coeffMap)
	return item
end

local function loadHighResFanProp(items, initData, model, slot_idx)	
	local mesh = loadAsync(brts.accessory, string.format("accessory_%d_0_0", model), false, initData.laneId)
	if mesh then
		local colorMap = loadAsync(brts.accessory, string.format("accessory_%d_color", model), false, initData.laneId)
		local normalMap = loadAsync(brts.accessory, string.format("accessory_%d_normal", model), false, initData.laneId)
		local coeffMap = loadAsync(brts.accessory, string.format("accessory_%d_coeff", model), false, initData.laneId)
		items[#items + 1] = futureCall(_bindHighResFanProp, initData, mesh, colorMap, normalMap, coeffMap, model, slot_idx)
	end
end

-----------------------------------------------------------------------------
local function _bindHighResFanAccessory(initData, mesh, colorMap, idx)
	local name = string.format("accessory_%d", idx)
	local slot = accessory_slots[idx]
	local item = createItem(name, slot, initData.laneId)
	item:addMeshLodPair(lod0, mesh, noBoundingBox, playerDrawOrder, playerDrawSubOrder_Accessory)

	local prop_mat = item:addMaterial("prop_mat")
	local hair_mat = item:addMaterial("hair_mat")
	local haircap_mat = item:addMaterial("haircap_mat")
	if colorMap then

		prop_mat:addTexture(ShaderParam.colorTexture, colorMap)

		hair_mat:addTexture(ShaderParam.colorTexture, colorMap)

		haircap_mat:addTexture(ShaderParam.colorTexture, colorMap)
	end
	return item
end

local function loadHighResFanAccessory(items, initData, prop_type, idx)	
	if idx < 1 and idx > #accessory_slots then return end
	local allow_missing = true
	
	local accessory_name = string.format("crowdhigh_prop_%d_%d_%d", prop_type, initData.Gender, initData.TournamentId)
	local accessory_mesh = loadAsync(brts.crowd_highres, accessory_name, allow_missing, initData.laneId)
	
	if accessory_mesh then
		local color_name = string.format("crowdhigh_prop_%d_%d_color", prop_type, initData.TeamId)
		local colorMap = loadAsync(brts.crowd_highres, color_name, allow_missing, initData.laneId)
	
		items[#items + 1] = futureCall(_bindHighResFanAccessory, initData, accessory_mesh, colorMap, idx)		
	end
end

-----------------------------------------------------------------------------

function player.loadHighResFan(initData)
	_disable_read_from_undefined_key(initData, true)

	local items = {}
	local generatedTextures = {}
	local assets = {}
	local isCreatedPlayer = initData.IsCreatedPlayer ~= 0
	local useAvatarHeadTexture = initData.UseAvatarHeadTexture ~= 0

	-- runtime overrides 
	local args = {
		use_psd = false,
		use_gpucompute = isCreatedPlayer,
		use_warpcloth = false,

		stamp_beard = true,
		static_jersey = false,
		disable_eyelashes = true, -- wrapping eyelash to head is not supported for HRC at the moment
	}

	if gIsRendererEnabled then
		-- shadows
		loadShadow(items, initData)

		-- load fan assets
		local assetId = initData.AssetId
		local weather = initData.Weather
		local skinTone = initData.SkinTone
			
		do
			-- body
			local body_name = string.format("crowdhigh_%d_%d_%d", assetId, weather, skinTone)
			local body_mesh = loadAsync(brts.crowd_highres, body_name, false, initData.laneId)

			local color_name = string.format("crowdhigh_%d_%d_%d_%d_color;debug_texture_color", assetId, weather, skinTone, initData.Variation)
			local colorMap = loadAsync(brts.crowd_highres, color_name, false, initData.laneId)
					
			local colorGeneratedMap = nil

			if not useAvatarHeadTexture then
				local facePaintId =  SETTING.EnableHRCFacepaint and initData.TeamId or 0
				local facePaintType = SETTING.EnableHRCFacepaint and initData.FacePaintType or 0

				local allow_missing=true
				local facepaint_color_name = string.format("crowdhigh_facepaint_%d_%d_color;crowdhigh_facepaint_0_0_color", facePaintId, facePaintType)
				local facepaintColorMap = loadAsync(brts.crowd_highres, facepaint_color_name, allow_missing, initData.laneId)

				if facepaintColorMap then			
					colorGeneratedMap = futureCall(compositeFacePaint, initData, colorMap, facepaintColorMap)
					generatedTextures[#generatedTextures + 1] = colorGeneratedMap
				end
			end

			local dirtMap = loadAsync(brts.crowd_highres, "crowdhigh_body_dk", false, initData.laneId)

			local body_item = futureCall(_bindHighResFanBody, initData, body_mesh, colorMap, colorGeneratedMap, dirtMap)
			items[#items + 1] = body_item
			
			-- head & hair		
			if useAvatarHeadTexture then
				loadHead(items, generatedTextures, initData, args, assets)
			else
				loadHead(items, generatedTextures, initData, args, assets, colorGeneratedMap)			
			end
			loadHair(items, initData, args)
			
			-- beard
			loadPlayerBeard(items, initData, args)
			
			-- jersey
			if initData.HasJersey ~= 0 then
				local hotspotAsset, competitionHotspot = loadHotspots(initData)
				local jersey_item, jersey_mesh
				if initData.EmbeddedJersey ~= 0 then
					jersey_item = body_item
					jersey_mesh = body_mesh
				end
				loadKitJersey(items, generatedTextures, initData, args, hotspotAsset, competitionHotspot, assets, jersey_item, jersey_mesh)
			end
		end

		-- cape -- this needs to be separate due to the fact it loads flag textures
		do
			if initData.HasCape ~= 0 then
				local allow_missing = true
				local proptype_2 = 22	
				
				local cape_name = string.format("crowdhigh_prop_%d_%d_%d", proptype_2, initData.Gender, initData.TournamentId)		
				local cape_mesh = loadAsync(brts.crowd_highres, cape_name, allow_missing, initData.laneId)
				
				if cape_mesh then
					local color_name = string.format("flag_%d_0_color;flag_0_0_color", initData.TeamId)
					local colorMap = loadAsync(brts.flag, color_name, false, initData.laneId)
					
					items[#items + 1] = futureCall(_bindHighResFanAccessory, initData, cape_mesh, colorMap, 3)
				end
			end
		end

		-- hrc props
		do
			loadHighResFanProp(items, initData, 38, 1) -- cell phone
			if SETTING.EnableHRCProps then		
				loadHighResFanProp(items, initData, 39, 2) -- megaphone
				loadHighResFanProp(items, initData, 40, 3) -- drum
				loadHighResFanProp(items, initData, 41, 4) -- drumstick
				loadHighResFanProp(items, initData, 42, 5) -- paper cup
				loadHighResFanProp(items, initData, 43, 6) -- water bottle
			end
		end
	end

	-- load non-appearance assets for external usage
	_loadRigamateAssets(assets, initData)

	return items, generatedTextures, assets
end

-----------------------------------------------------------------------------
local function _loadHighresCharacterRigamateAssets(assets, initData)
	local gender = initData.Gender
	local rigamate_type = initData.RigamateType

	-- lod1 rigamate on lod0. We just want shoulder correction.
	-- Rigamate ONLY on lod0.

	-- FB Rigamate Expressions
	local body1_asset_name = string.format("rigamate_expr_asset_body_%d_1_%d", rigamate_type, gender)

	-- lod1 rigamate on lod0. We just want shoulder correction.
	-- Rigamate ONLY on lod0.
	assets.BodyLod0Asset = loadAsync(brts.rigamate, body1_asset_name, false, initData.laneId)

	assets.FaceAsset= loadAsync(brts.rigamate, "rigamate_expr_asset_face_simple", false, initData.laneId)
	assets.EyesAsset = loadAsync(brts.rigamate, "rigamate_expr_asset_face_eyes", false, initData.laneId)
end

function player.loadHighresSlc(initData)
	_disable_read_from_undefined_key(initData, true)

	local items = {}
	local generatedTextures = {}
	local assets = {}
	
	-- runtime overrides 
	local args = {
		use_psd = false,
		use_gpucompute = true,
		use_warpcloth = false,

		stamp_beard = true,

		static_jersey = false,
		static_shorts = false,
		static_socks = false,
		disable_eyelashes = false,
		force_generic = false
	}

	if gIsRendererEnabled then
		-- hotspots
		local hotspotAsset, competitionHotspot = nil, nil --loadHotspots(initData)
		
		-- schedule texture generation first

		-- body
		loadUpperBody(items, generatedTextures, initData, args, assets)
		loadLowerBody(items, generatedTextures, initData, args, assets)

		-- head
		loadHead(items, generatedTextures, initData, args, assets)
		loadHair(items, initData, args)

		-- wardrobe outfit
		loadTop0(items, initData)
		loadTop1(items, initData)
		loadBottom0(items, initData)
		loadBottom1(items, initData)

		-- shoes and socks
		loadShoes(items, initData)
		loadSocks(items, generatedTextures, initData, args, hotspotAsset, assets)

		-- accessory
		for idx, accessory in ipairs(initData.Accessories) do
			loadAccessory(items, initData, args, idx, accessory)
		end
		
		-- shadows
		loadShadow(items, initData)
	end

	-- load non-appearance assets for external usage
	_loadHighresCharacterRigamateAssets(assets, initData)
	return items, generatedTextures, assets
end
-----------------------------------------------------------------------------

function player.loadSetPieceActor(initData)
	_disable_read_from_undefined_key(initData, true)

	local items = {}
	local generatedTextures = {}
	local assets = {}
	
	-- runtime overrides 
	local args = {
		use_psd = false,
		use_gpucompute = true,
		use_warpcloth = false,

		stamp_beard = true,

		static_jersey = false,
		static_shorts = false,
		static_socks = false,
		disable_eyelashes = false,
		force_generic = false
	}

	if gIsRendererEnabled then
		-- hotspots
		local hotspotAsset, competitionHotspot = nil, nil --loadHotspots(initData)
		
		-- schedule texture generation first

		-- body
		loadUpperBody(items, generatedTextures, initData, args, assets)
		loadLowerBody(items, generatedTextures, initData, args, assets)

		-- head
		loadHead(items, generatedTextures, initData, args, assets)
		loadHair(items, initData, args)

		-- wardrobe outfit
		loadTop0(items, initData)
		loadTop1(items, initData)
		loadBottom0(items, initData)
		loadBottom1(items, initData)

		-- shoes and socks
		loadShoes(items, initData)
		loadSocks(items, generatedTextures, initData, args, hotspotAsset, assets)

		-- accessory
		for idx, accessory in ipairs(initData.Accessories) do
			loadAccessory(items, initData, args, idx, accessory)
		end
		
		-- shadows
		loadShadow(items, initData)
	end

	-- load non-appearance assets for external usage
	_loadHighresCharacterRigamateAssets(assets, initData)
	return items, generatedTextures, assets
end
-----------------------------------------------------------------------------

return player
