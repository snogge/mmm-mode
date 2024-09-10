(require 'ert)

(ert-deftest pass-expected ()
  (should t))

(ert-deftest pass-unexpected ()
  :expected-result :failed
  (should t))

(ert-deftest fail-expected ()
  :expected-result :failed
  (should nil))

(ert-deftest fail-unexpected ()
  (should nil))

(ert-deftest skipped ()
  (skip-unless nil))
