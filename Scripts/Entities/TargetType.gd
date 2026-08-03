
enum TargetType {
	NONE = 0,
	
	FRIENDLY = 				1 << 0,
	ENEMY = 				1 << 1,
	
	SEAL = 					1 << 2,
	NON_SEAL = 				1 << 3,
	COIN_PIECE = 			1 << 4,
	FINGER_RING = 			1 << 5,
	FINGER = 				1 << 6,
	ABILITY_PIECE = 		1 << 7,
	
	################################################################################################
	
	ANY = FRIENDLY | ENEMY,
	
	SEAL_FRIENDLY = SEAL | FRIENDLY,
	SEAL_ENEMY = SEAL | ENEMY,
	SEAL_ANY = SEAL | ANY,
	
	NON_SEAL_FRIENDLY = NON_SEAL | FRIENDLY,
	NON_SEAL_ENEMY = NON_SEAL | ENEMY,
	NON_SEAL_ANY = NON_SEAL | ANY,
	
	COIN_PIECE_FRIENDLY = COIN_PIECE | FRIENDLY,
	COIN_PIECE_ENEMY = COIN_PIECE | ENEMY,
	COIN_PIECE_ANY = COIN_PIECE | ANY,
	
	FINGER_RING_FRIENDLY = FINGER_RING | FRIENDLY,
	FINGER_RING_ENEMY = FINGER_RING | ENEMY,
	FINGER_RING_ANY = FINGER_RING | ANY,
	
	FINGER_FRIENDLY = FINGER | FRIENDLY,
	FINGER_ENEMY = FINGER | ENEMY,
	FINGER_ANY = FINGER | ANY,
	
	ABILITY_PIECE_FRIENDLY = ABILITY_PIECE | FRIENDLY,
	ABILITY_PIECE_ENEMY = ABILITY_PIECE | ENEMY,
	ABILITY_PIECE_ANY = ABILITY_PIECE | ANY,
	
	ALL = Util.INT_MAX,
}

static func isTargetFriendly(playerModel : PlayerModel, targetModel : RefCounted) -> bool:
	if not targetModel.has_method("getPlayerModel"):
		return false
	return (playerModel == targetModel.getPlayerModel())

static func isTargetFriendlinessEqual(targetType : TargetType, playerModel : PlayerModel, targetModel : RefCounted) -> bool:
	return isTargetFriendly(playerModel, targetModel) == Util.hasBitVal(targetType, TargetType.FRIENDLY)

static func isValidFriendliness(targetType : TargetType, playerModel : PlayerModel, targetModel : RefCounted) -> bool:
	if Util.hasBitVal(targetType, TargetType.ANY):
		return true
	elif isTargetFriendlinessEqual(targetType, playerModel, targetModel):
		return true
	return false

static func isValidModel(targetType : TargetType, playerModel : PlayerModel, targetModel : RefCounted) -> bool:
	if not Util.hasBitVal(targetType, TargetType.ANY) and not isValidFriendliness(targetType, playerModel, targetModel):
		return false
	if Util.hasBitVal(targetType, TargetType.COIN_PIECE) and (not targetModel is CoinPieceModel):
		return false
	if Util.hasBitVal(targetType, TargetType.SEAL) and (not targetModel is CoinPieceModel or targetModel.getSealModel() == null):
		return false
	if Util.hasBitVal(targetType, TargetType.NON_SEAL) and (not targetModel is CoinPieceModel or targetModel.getSealModel() != null):
		return false
	if Util.hasBitVal(targetType, TargetType.ABILITY_PIECE) and (not targetModel is CoinPieceModel or targetModel.abilityScript == null):
		return false
	
	if Util.hasBitVal(targetType, TargetType.FINGER) and (not targetModel is FingerModel):
		return false
	if Util.hasBitVal(targetType, TargetType.FINGER_RING) and (not targetModel is FingerModel or targetModel.getFingerRingModel() == null):
		return false
	
	return true
	
"""
#Targets a coin piece and the target is a coin piece model
if Util.hasBitVal(targetType, TargetType.COIN_PIECE) and targetModel is CoinPieceModel:
	if isValidFriendliness(targetType, playerModel, targetModel):
		return true
#Targets a seal and the target is a coin piece model
if Util.hasBitVal(targetType, TargetType.SEAL) and targetModel is CoinPieceModel and targetModel.getSealModel() != null:
	if isValidFriendliness(targetType, playerModel, targetModel):
		return true
#Targets a non-seal coin piece model
if Util.hasBitVal(targetType, TargetType.NON_SEAL) and targetModel is CoinPieceModel and targetModel.getSealModel() == null:
	if isValidFriendliness(targetType, playerModel, targetModel):
		return true
#Targets a coin piece model with an ability
if Util.hasBitVal(targetType, TargetType.ABILITY_PIECE) and targetModel is CoinPieceModel and targetModel.abilityScript != null:
	if isValidFriendliness(targetType, playerModel, targetModel):
		return true
#Targets a finger ring and the target is a finger ring model
if Util.hasBitVal(targetType, TargetType.FINGER_RING) and targetModel is FingerRingModel:
	if isValidFriendliness(targetType, playerModel, targetModel):
		return true
#Targets a finger and the target is a finger model
if Util.hasBitVal(targetType, TargetType.FINGER) and targetModel is FingerModel and not targetModel.destroyed:
	if isValidFriendliness(targetType, playerModel, targetModel):
		return true
return false
"""

static func isValidNode(targetType : TargetType, playerModel : PlayerModel, targetNode : Node) -> bool:
	return isValidModel(targetType, playerModel, getTargetNodeToModel(targetType, targetNode))

static func getTargetNodeToModel(targetType : TargetType, viewNode : Node) -> Variant:
	if Util.hasBitVal(targetType, Entities.TargetType.FINGER) and viewNode is FingerRingNode:
		return viewNode.getModel().getFingerModel()
	else:
		return viewNode.getModel()
