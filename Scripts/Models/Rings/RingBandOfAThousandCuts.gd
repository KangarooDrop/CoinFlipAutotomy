extends RingModel

class_name RingBandOfAThousandCuts

const SPIN_INC : int = 1

####################################################################################################

func getLocID() -> String: return super.getLocID() + "BAND_OF_A_THOUSAND_CUTS"

func _getBaseData() -> Dictionary:
	var baseData : Dictionary = super._getBaseData()
	baseData.merge(
	{
		
	}, true)
	return baseData

func getTexturePath() -> String:
	return super.getTexturePath() + "band_of_a_thousand_cuts.png"

####################################################################################################

func onAfterSpinChanged(matchState : MatchState, _playerModel : PlayerModel, amount : int, _source : RefCounted) -> bool:
	if amount >= 0:
		return false
	popNode()
	await CmdSpin.addSpin(matchState, getPlayerModel(), SPIN_INC, self)
	return true
