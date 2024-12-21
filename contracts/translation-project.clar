;; Translation Project Contract

(define-data-var project-id-nonce uint u0)

(define-map projects
  { project-id: uint }
  {
    owner: principal,
    source-language: (string-ascii 10),
    target-language: (string-ascii 10),
    content-hash: (buff 32),
    status: (string-ascii 20),
    reward: uint,
    deadline: uint
  }
)

(define-map translations
  { project-id: uint, translator: principal }
  {
    translation-hash: (buff 32),
    status: (string-ascii 20),
    votes: uint
  }
)

(define-public (create-project (source-language (string-ascii 10)) (target-language (string-ascii 10)) (content-hash (buff 32)) (reward uint) (deadline uint))
  (let
    (
      (project-id (var-get project-id-nonce))
      (new-project {
        owner: tx-sender,
        source-language: source-language,
        target-language: target-language,
        content-hash: content-hash,
        status: "open",
        reward: reward,
        deadline: deadline
      })
    )
    (map-set projects { project-id: project-id } new-project)
    (var-set project-id-nonce (+ project-id u1))
    (ok project-id)
  )
)

(define-public (submit-translation (project-id uint) (translation-hash (buff 32)))
  (let
    (
      (project (unwrap! (map-get? projects { project-id: project-id }) (err u404)))
    )
    (asserts! (is-eq (get status project) "open") (err u403))
    (map-set translations
      { project-id: project-id, translator: tx-sender }
      {
        translation-hash: translation-hash,
        status: "pending",
        votes: u0
      }
    )
    (ok true)
  )
)

(define-read-only (get-project (project-id uint))
  (map-get? projects { project-id: project-id })
)

(define-read-only (get-translation (project-id uint) (translator principal))
  (map-get? translations { project-id: project-id, translator: translator })
)

