;; Enhanced Raffle Smart Contract with Improved Variable Names and Updated Constants

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-RAFFLE-INACTIVE (err u101))
(define-constant ERR-RAFFLE-IN-PROGRESS (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u103))
(define-constant ERR-NO-PARTICIPANTS (err u104))
(define-constant ERR-RAFFLE-ENDED (err u105))
(define-constant ERR-INVALID-INPUT (err u106))
(define-constant ERR-NOT-WINNER (err u107))
(define-constant ERR-PRIZE-ALREADY-CLAIMED (err u108))

;; Data Variables
(define-data-var raffle-state bool false)
(define-data-var ticket-cost uint u1000000) ;; 1 STX
(define-data-var raffle-end-block uint u0)
(define-data-var winning-participant (optional principal) none)
(define-data-var prize-claim-status bool false)
(define-data-var minimum-participants uint u5)
(define-data-var max-tickets-per-participant uint u10)
(define-data-var raffle-fee-rate uint u5) ;; 5% fee

;; Maps
(define-map participant-tickets principal uint)
(define-map participant-registry {index: uint} {address: principal})
(define-map participant-indices principal uint)

;; Variables
(define-data-var participant-count uint u0)
(define-data-var total-tickets-sold uint u0)

;; Private Functions
(define-private (is-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-raffle-active)
  (var-get raffle-state)
)

(define-private (register-new-participant (address principal))
  (let (
    (current-count (var-get participant-count))
    (new-count (+ current-count u1))
  )
    (map-insert participant-registry {index: new-count} {address: address})
    (map-insert participant-indices address new-count)
    (var-set participant-count new-count)
  )
)

(define-private (generate-random-number (seed uint))
  (let (
    (combined-value (+ (var-get participant-count) seed block-height))
    (random-value (mod combined-value (var-get participant-count)))
  )
    (if (is-eq random-value u0)
      u1
      (+ random-value u1)
    )
  )
)

(define-private (calculate-raffle-fee (amount uint))
  (/ (* amount (var-get raffle-fee-rate)) u100)
)

;; Public Functions
(define-public (initialize-raffle (duration uint) (price uint) (min-participants uint) (max-tickets uint))
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (not (is-raffle-active)) ERR-RAFFLE-IN-PROGRESS)
    (asserts! (> duration u0) ERR-INVALID-INPUT)
    (asserts! (> price u0) ERR-INVALID-INPUT)
    (asserts! (>= min-participants u2) ERR-INVALID-INPUT)
    (asserts! (> max-tickets u0) ERR-INVALID-INPUT)
    (var-set raffle-state true)
    (var-set ticket-cost price)
    (var-set raffle-end-block (+ block-height duration))
    (var-set minimum-participants min-participants)
    (var-set max-tickets-per-participant max-tickets)
    (var-set prize-claim-status false)
    (var-set participant-count u0)
    (var-set total-tickets-sold u0)
    (ok true)
  )
)

(define-public (purchase-tickets (quantity uint))
  (let (
    (buyer tx-sender)
    (price (var-get ticket-cost))
    (total-purchase-cost (* price quantity))
    (current-ticket-count (default-to u0 (map-get? participant-tickets buyer)))
    (new-ticket-count (+ current-ticket-count quantity))
  )
    (asserts! (is-raffle-active) ERR-RAFFLE-INACTIVE)
    (asserts! (<= block-height (var-get raffle-end-block)) ERR-RAFFLE-ENDED)
    (asserts! (>= (stx-get-balance buyer) total-purchase-cost) ERR-INSUFFICIENT-BALANCE)
    (asserts! (<= new-ticket-count (var-get max-tickets-per-participant)) ERR-INVALID-INPUT)
    (try! (stx-transfer? total-purchase-cost buyer (as-contract tx-sender)))
    (map-set participant-tickets buyer new-ticket-count)
    (match (map-get? participant-indices buyer)
      index true
      (register-new-participant buyer)
    )
    (var-set total-tickets-sold (+ (var-get total-tickets-sold) quantity))
    (ok new-ticket-count)
  )
)

(define-public (conclude-raffle)
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (is-raffle-active) ERR-RAFFLE-INACTIVE)
    (asserts! (>= block-height (var-get raffle-end-block)) ERR-RAFFLE-INACTIVE)
    (let (
      (total-participants (var-get participant-count))
      (random-seed block-height)
    )
      (asserts! (>= total-participants (var-get minimum-participants)) ERR-NO-PARTICIPANTS)
      (let (
        (winner-index (generate-random-number random-seed))
        (winner-info (unwrap! (map-get? participant-registry {index: winner-index}) ERR-NO-PARTICIPANTS))
      )
        (var-set winning-participant (some (get address winner-info)))
        (var-set raffle-state false)
        (ok (get address winner-info))
      )
    )
  )
)

(define-public (claim-raffle-prize)
  (let (
    (claimer tx-sender)
    (winner (unwrap! (var-get winning-participant) ERR-NO-PARTICIPANTS))
  )
    (asserts! (is-eq claimer winner) ERR-NOT-WINNER)
    (asserts! (not (var-get prize-claim-status)) ERR-PRIZE-ALREADY-CLAIMED)
    (let (
      (total-prize-pool (var-get total-tickets-sold))
      (raffle-fee (calculate-raffle-fee total-prize-pool))
      (winner-prize (- total-prize-pool raffle-fee))
    )
      (try! (as-contract (stx-transfer? winner-prize tx-sender winner)))
      (var-set prize-claim-status true)
      (ok winner-prize)
    )
  )
)

(define-read-only (get-ticket-price)
  (ok (var-get ticket-cost))
)

(define-read-only (get-raffle-info)
  (ok {
    active: (var-get raffle-state),
    end-block: (var-get raffle-end-block),
    current-block: block-height,
    total-tickets: (var-get total-tickets-sold),
    participant-count: (var-get participant-count),
    minimum-participants: (var-get minimum-participants),
    max-tickets-per-participant: (var-get max-tickets-per-participant)
  })
)

(define-read-only (get-participant-tickets (address principal))
  (ok (default-to u0 (map-get? participant-tickets address)))
)

(define-read-only (get-winning-participant)
  (ok (var-get winning-participant))
)

(define-read-only (get-prize-info)
  (ok {
    claimed: (var-get prize-claim-status),
    total-prize-pool: (var-get total-tickets-sold)
  })
)

(define-public (withdraw-raffle-fees)
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (not (is-raffle-active)) ERR-RAFFLE-INACTIVE)
    (asserts! (var-get prize-claim-status) ERR-PRIZE-ALREADY-CLAIMED)
    (let (
      (total-sales (var-get total-tickets-sold))
      (fee (calculate-raffle-fee total-sales))
    )
      (try! (as-contract (stx-transfer? fee tx-sender CONTRACT-OWNER)))
      (ok fee)
    )
  )
)

(define-public (cancel-active-raffle)
  (begin
    (asserts! (is-owner) ERR-UNAUTHORIZED)
    (asserts! (is-raffle-active) ERR-RAFFLE-INACTIVE)
    (asserts! (< (var-get participant-count) (var-get minimum-participants)) ERR-INVALID-INPUT)
    (var-set raffle-state false)
    (ok true)
  )
)

(define-public (refund-participant-tickets)
  (let (
    (participant tx-sender)
    (ticket-count (default-to u0 (map-get? participant-tickets participant)))
    (refund-amount (* ticket-count (var-get ticket-cost)))
  )
    (asserts! (not (is-raffle-active)) ERR-RAFFLE-IN-PROGRESS)
    (asserts! (> ticket-count u0) ERR-INVALID-INPUT)
    (try! (as-contract (stx-transfer? refund-amount tx-sender participant)))
    (map-delete participant-tickets participant)
    (map-delete participant-indices participant)
    (var-set total-tickets-sold (- (var-get total-tickets-sold) ticket-count))
    (ok refund-amount)
  )
)