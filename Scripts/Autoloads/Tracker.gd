extends Node

enum TRACKING_KEY
{
	MATCH_STATE_SERIALIZE,
	PLAYER_SERIALIZE,
	COIN_FACE_SERIALIZE,
	COIN_PIECE_SERIALIZE,
	SEAL_SERIALIZE,
	HAND_SERIALIZE,
	FINGER_SERIALIZE,
	RING_SERIALIZE,
}

var _timesUsecs : Dictionary[TRACKING_KEY, int] = {}

func addTimeUsecs(trackingKey : TRACKING_KEY, amount : int) -> void:
	if not _timesUsecs.has(trackingKey):
		_timesUsecs[trackingKey] = 0
	_timesUsecs[trackingKey] += amount

func printTimes() -> void:
	for key : TRACKING_KEY in _timesUsecs:
		print(TRACKING_KEY.keys()[key].capitalize(), ": ", float(_timesUsecs[key])/1_000_000.0, " s")

func clear() -> void:
	_timesUsecs.clear()
