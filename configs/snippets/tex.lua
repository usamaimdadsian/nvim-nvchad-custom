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
  ))
}

