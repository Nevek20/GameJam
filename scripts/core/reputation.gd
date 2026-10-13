class_name Reputation
extends RefCounted
## Regras puras de reputação (sem estado). O estado fica no autoload ReputationState.

enum Standing { POSITIVE, QUESTIONABLE, NEGATIVE }


## Negativo = se aliou ao exército. Senão, faixa de heroísmo decide.
static func compute_standing(heroism: float, allied: bool, config: ReputationConfig) -> Standing:
	if allied:
		return Standing.NEGATIVE
	if heroism >= config.positive_threshold:
		return Standing.POSITIVE
	return Standing.QUESTIONABLE
