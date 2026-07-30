extends Sprite2D

class_name FingerGib

const H_VEL : float = 320.0
const INITIAL_V_VEL : float = 640.0
const GRAV : float = 1440.0
const ANGULAR_VEL : float = PI*8.0

var velocity : Vector2 = Vector2.ZERO
var angularVel : float = 0.0

func setFromFingerNode(fingerNode : FingerNode) -> void:
	self.texture = fingerNode.sprite.texture
	self.region_rect = fingerNode.sprite.region_rect
	self.flip_h = fingerNode.sprite.flip_h
	
	velocity.x = randf() * H_VEL
	if fingerNode.sprite.flip_h:
		velocity.x *= -1.0
	velocity.y = -INITIAL_V_VEL
	angularVel = (randf()*0.5 + 0.5) * ANGULAR_VEL * (-1.0 if randi()%2==0 else 1.0)
	
	offset = region_rect.size/2.0 - getImageBoundingBox(texture.get_image(), region_rect).get_center()
	if fingerNode.sprite.flip_h:
		offset.x = -offset.x
	position -= offset

func _process(delta: float) -> void:
	velocity.y += GRAV * delta
	position += velocity * delta
	rotation += angularVel * delta

static func getImageBoundingBox(image : Image, regionRect : Rect2) -> Rect2:
	var tlc : Vector2 = regionRect.size
	var brc : Vector2 = Vector2.ZERO
	var foundPoint : bool = false
	for _x in range(regionRect.size.x):
		for _y in range(regionRect.size.y):
			if image.get_pixel(int(regionRect.position.x + _x), int(regionRect.position.y + _y)).a == 0:
				continue
			foundPoint = true
			if _x < tlc.x:
				tlc.x = _x
			if _y < tlc.y:
				tlc.y = _y
			if _x > brc.x:
				brc.x = _x
			if _y > brc.y:
				brc.y = _y
	if not foundPoint:
		return Rect2(regionRect.size/2.0, Vector2.ZERO)
	return Rect2(tlc, brc - tlc + Vector2.ONE)

func getCenterFilled() -> Vector2:
	var avgPoint : Vector2 = Vector2.ZERO
	var numPoints : int = 0
	var textureImage : Image = texture.get_image()
	for _x in range(region_rect.size.x):
		for _y in range(region_rect.size.y):
			if textureImage.get_pixel(int(region_rect.position.x + _x), int(region_rect.position.y + _y)).a > 0:
				avgPoint.x += _x
				avgPoint.y += _y
				numPoints += 1
	if numPoints == 0:
		return region_rect.size/2.0
	return avgPoint/numPoints
