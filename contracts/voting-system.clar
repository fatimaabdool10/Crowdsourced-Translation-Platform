;; Voting System Contract

(define-fungible-token vote-token)

(define-map votes
  { project-id: uint, translator: principal, voter: principal }
  { amount: uint }
)

(define-public (vote (project-id uint) (translator principal) (amount uint))
  (let
    (
      (translation (unwrap! (contract-call? .translation-project get-translation project-id translator) (err u404)))
    )
    (asserts! (is-eq (get status translation) "pending") (err u403))
    (try! (ft-transfer? vote-token amount tx-sender (as-contract tx-sender)))
    (map-set votes
      { project-id: project-id, translator: translator, voter: tx-sender }
      { amount: amount }
    )
    (ok true)
  )
)

(define-read-only (get-votes (project-id uint) (translator principal))
  (default-to u0
    (get amount
      (map-get? votes { project-id: project-id, translator: translator, voter: tx-sender })
    )
  )
)

