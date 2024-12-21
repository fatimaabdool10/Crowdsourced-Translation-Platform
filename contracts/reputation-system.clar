;; Reputation System Contract

(define-map translator-reputation
  { translator: principal }
  { score: uint }
)

(define-public (update-reputation (translator principal) (quality uint) (speed uint))
  (let
    (
      (current-score (default-to { score: u0 } (map-get? translator-reputation { translator: translator })))
      (new-score (+ (get score current-score) (+ quality speed)))
    )
    (map-set translator-reputation
      { translator: translator }
      { score: new-score }
    )
    (ok true)
  )
)

(define-read-only (get-reputation (translator principal))
  (default-to { score: u0 } (map-get? translator-reputation { translator: translator }))
)

