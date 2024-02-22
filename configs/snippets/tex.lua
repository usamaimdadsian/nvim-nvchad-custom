-- https://www.ejmastnak.com/tutorials/vim-latex/luasnip/
--
return {
	s("name", t("Usama Imdad!!")),
  s("image",fmta(
    [[
      \begin{figure}[h]
      \centering
        \includegraphics[width=0.5\textwidth, angle=0]{images/<>.png}
        \caption{Softmax}
        % \label{fig:fig1}
      \end{figure}
    ]], {i(1)}
  )),
  s("Eq",fmta(
    [[
      \[<>\]
    ]], {i(1)}
  )),
  s("eq",fmta(
    [[
      \(<>\)
    ]], {i(1)}
  )),
  s("fn_piecewise",fmta(
    [[
    |x| = \left\{ \begin{array}{cl}
                x & : \ x \geq 0 \\
                -x & : \ x < 0
                \end{array} \right.
    ]], {i(1)}
  )),
  s("list_enum",fmta(
    [[
    \begin{enumerate}
      \item <>
    \end{enumerate}
    ]], {i(1)}
  )),
}

