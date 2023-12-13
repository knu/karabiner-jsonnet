;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((jsonnet-mode . ((eval . (add-hook 'after-save-hook #'(lambda () (let (compilation-read-command) (projectile-compile-project nil))) t t)))))
