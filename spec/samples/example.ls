take = (n, [x, ...xs]:list) -->
  | n <= 0     => []
  | empty list => []
  | otherwise  => [x] ++ take n - 1, xs
take 2, [1 2 3 4 5] #=> [1, 2]

take-three = take 3
take-three [3 to 8] #=> [3, 4, 5]

# Function composition, 'reverse' from prelude.ls
last-three = reverse >> take-three >> reverse
last-three [1 to 8] #=> [6, 7, 8]
