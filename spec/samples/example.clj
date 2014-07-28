;; ClojureScript does not hoist variables
;; this function will issue a warning

(defn print-name []
  (println "Hello, " name)
  (let [name "Bob"]))
