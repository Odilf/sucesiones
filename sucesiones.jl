### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# ╔═╡ ee6af700-2e4f-48fb-b364-d16240675b7a
using PlutoUI

# ╔═╡ db76cd30-4697-4185-b6b2-7e587ccd970e
using Memoize

# ╔═╡ 6c214774-23ca-4159-9796-28c322b0c91b
md"""
## 1. Sines

The function $\sin(n)$ is cyclic, so it makes sense to use it. We can adjust its phase to thirds by multiplying by $\frac{2\pi}{3}$: 

$$a_n = \sin\left( \frac{2\pi}{3} n \right)$$

However, I used $\tau$ back then and, while it certainly is a questionable choice, I will respect it today. 

$$a_n = \sin\left( \frac{n \tau}{3} \right)$$

Thus, we have $\frac{\sqrt{3}}{2}$, $-\frac{\sqrt{3}}{2}$, $0$, ...

We can normalize these values by multiplying by the reciprocals, 
$\frac{2}{\sqrt{3}} = \frac{2 \sqrt{3}}{3}$: 

$$a_n = \sin\left( \frac{n \tau}{3} \right) \frac{2 \sqrt{3}}{3}$$

To get $1$, $-1$, $0$, ...

And then we can square to get the correct signs: 

$$a_n = \left(
	\sin\left( \frac{n \tau}{3} \right) \frac{2 \sqrt{3}}{3}
\right)^2$$

So if we just multiply by the index, $n$, we have our series!

$$a_n = n \left(
	\sin\left( \frac{n \tau}{3} \right) \frac{2 \sqrt{3}}{3}
\right)^2$$

"""

# ╔═╡ 38302ed6-6bbb-4c19-8ae9-802b880497c0
md"""
It's interesting to note that this method wouldn't work so nicely with periods greater than 3. We were lucky that the reciprocal is the same for the two values that weren't 0. We can't just divide because we would have a problem with $\frac{0}{0}$. 
"""

# ╔═╡ 5862bfb5-b6ac-409f-a9cd-24fa6ac13861
md"""

New challenge: sines, and any basic cyclic functions, are banned. What to do now?

## 2. Complex numbers

Acutally, there is quite a simple workaround, but it's kind of cheesy. 

We know that complex numbers can be expressed as 

$$z = e^{\tau \theta i} = \cos(\theta) + i \sin(\theta)$$

If they have an argument of $1$. So, if we just take the imaginary part of $z$, we have a sine: 

$$\Im(e^{\tau \theta i}) = \sin(\theta)$$

And this way we can substitute our previous result. 

$$b_n = n \left(
	\Im(e^{\tau \left( \frac{n \tau}{3} \right) \frac{2 \sqrt{3}}{3} i})
\right)^2$$

"""

# ╔═╡ 95cea978-dfed-4212-8ed9-450d42303ac9
md"""
## 3. Check multiples

Let's try to solve it cleanly, with the definition of multples. 

A number $n$ is said to be a multiple of $p$ if: 

$$\exists k \in \mathbb{Z} : n = p \cdot k$$

So if we're searching for positive multples of 3, we want the following condition: 

$$\exists k \in \mathbb{N} : n = 3k$$

Saying $n = 3k$ is the same as saying $3k - n = 0$. We don't know value of $k$, so what could we do?

Well, we can just try all of the values of $k$. If (and only if) $n$ is actually a multiple of $3$ the previous difference will be $0$. If we take the product of all the differences, we will have a $0$ when $n$ is a multiple of $3$ and a different number otherwise. 

Things are going to get messy, so let's call this product $p_n$:

$$p_n = \prod_{k=1}^{\infty} (3k - n)$$
"""

# ╔═╡ 9a008407-cb25-42da-8855-45e79e1693cc
md"""
Now we have to leverage some special property that $0$ has. One such property is that $0! = 1$. The only other number that has $1$ as its factorial is $1! = 1$, but if we just multiply $p_n$ by $2$ we will have our desired effect. We should also square it to avoid getting the gamma definition of the factorial. 

This way, not only every other number will not return $1$, *it will return an even number* (since every factorial after $2!$ has a factor of $2$). To summirize: 

$$2{p_n}^2 = \begin{cases} 
      1 & \textrm{if} & x = 0 \\
      \textrm{even} & \textrm{if} & x \ne 0
\end{cases}$$

Now we can use a property of the parity of numbers. Namely, the fact that
$(-1)^{2k} = 1$ and $(-1)^{2k + 1} = -1$. We can reduce to 0 the odd case by adding $1$ and, since that will retun $2$ on the even case, we can divide by $2$. Thus we have a solution: 

$$c_n = \frac{n}{2} \left(
	(-1)^{2{p_n}^2!} + 1
\right)$$
"""

# ╔═╡ b50e5882-11dc-4da3-a408-41f070189ef8
function c(n::Integer)
	p = prod(p -> 3*p - n, 1:n)

	# If i dont do this it will never compute anything past ~10
	p = round(Int, p / factorial(n)) # n! is a random biggo number

	r = n * ((-1)^factorial(big(2*p^2)) + 1) ÷ 2
end

# ╔═╡ 7986eebe-6a51-4d85-93f8-4e9c4812c4e0
product = [c(n) for n in 1:20]

# ╔═╡ ca4207ca-70c3-46ce-9ce7-0f1e74e5885e
md"""
It's easy to see that the product will never have to go past $n$ (or even $\frac{n}{3}$). I find the infinity more mathematically aesthetic, but I used $n$ on the implementation. Also we have to reduce the product because we are taking a hilariously big factorial which will never be able to compute after a certain point. We can do this because we can proove that the parity is the only important aspect and will remain the same. 

This solution is very clear and very easy to modify for other periods (just replace the $3$!). 
"""

# ╔═╡ f8a8a4a6-da5e-44fa-926a-da697da021e3
md"""
## 4. Subtraction

Another approach is to cyclify our series, by substracting $3$ every third element. 

Let's try to subtract $3$ after the third element just once. We can separate values bigger and smaller than $3$ by subtracting... $3.5$. It's quite ugly, but this way we have negative values between $1$ and $3$ and positive values afterwards. 

We can extract the sign of a value $x$ if we do $\frac{|x|}{x}$, where $x \ne 0$, to avoid using less conventional notation. 

We can do the same thing as for solution $3$ to convert these values into $0$ before and $1$ after: 

$$\frac{1}{2}\left(\frac{|n - 3.5|}{n - 3.5} + 1 \right)$$

So if subtract that to $n$ we would have $1$, $2$, $3$, $1$, $2$, $3$, $4$, ...

We have the same series, but shifted over by $3$! This means we can do the same thing but for $n + 3$. Then we would have to do the same but for $n + 6$, then $n + 9$, etc...

So we have sum where the general term is $(n - 3k) - 3.5)$. As we only care for the sign and not the magnitude, we can de-uglify the expresion by multiplying by $2$. This way, the expresion is as follows: 

$$s_n = n - \frac{3}{2} \sum_{k = 1}^{\infty} \left(
	\frac{|2n - 6k - 7|}{2n + 6k - 7} + 1
\right)$$

The expression $s_n$ returns $1$, $2$, $3$, $1$, $2$, $3$, ... indefinitely.

The easiest way to make it have $0$ every third element is to subtract $2$, offset it and do the same thing as with the sines. Back in the day for some reason I did it using factorials. The expression in question is the following: 

$$d_n = - n \left( \frac{s_n! - s_n}{3} - 1 \right)$$

There's no justification for this last step other than "it just kinda works".
"""

# ╔═╡ b2427cde-9b92-4ed2-8900-926120ae8857
function d(n::Integer)
	a = k -> 2*n - 6*k - 7
	b = sum(3/2 * [abs(a(i)) ÷ a(i) + 1 for i in 0:n])

	b = round(Integer, b)

	c = n - b # counter
	-n * ((factorial(c) - c) ÷ 3 - 1)
end

# ╔═╡ 9ef70702-df81-417c-ad5f-67ce79edf00d
subtract = [d(n) for n in 1:20]

# ╔═╡ 3f1cf7c4-d1c4-4520-9408-bb2e2d1704af
md"""
## 5. Unbeknownst recursion

The previous solution was very recursive in nature. Could we just use recursion? 

This is the last, and might be the most interesting. Looking back, I'm very surprised, since I hadn't heard of recursion back then and I was kinda redescovering it myself. 

Let's take 

$$s_n = \frac{1}{2}\left(\frac{|2n - 7|}{2n - 7} + 1 \right)$$

Which is useful, because: 

$$n - s_n = \begin{cases} 
      n & n < 3 \\
      n - 3 & n \ge 3
\end{cases}$$

So we can just feed our series into itself, recursively: 

$$c_n = n - s_{n - s_{n - s_{n - s_n ...}}}$$

We can modify $s_n$ to implement this recursion 

$$s_n = \frac{1}{2}\left(\frac{|2n - 7|}{2n - 7} + 1 \right) + s_{n-3}$$

And then we have that 

$$c_n = n - s_n$$

Which can be rewritten in one expression as: 

$$c_n = n - \frac{1}{2}\left(\frac{|2n - 7|}{2n - 7} + 1 \right) - (n - 3 - c_{n-3})$$
"""

# ╔═╡ 14adddd6-ba2f-43eb-8e1e-2ce2303c5d96
md"""
However, this recursion is infinite. Any implementation as is would throw a `StackOverflow` error. We could define that $e_n = 0$ for $n \le 0$. However, we can also prove it!

Let's take 

$$s_n = \frac{1}{2}\left(\frac{|2n - 7|}{2n - 7} + 1 \right)$$

We can see that $s_0 = s_1 = s_2 = 0$. This is the base case. We could use induction to prove the rest of the cases but it's pretty straightforward to see that any $n < 0$ would also return $0$. So, taking the convergence test

$$\lim_{n \to -\infty} s_n = 0$$

Which means that the recursive sum converges. 

With the counter, we can do the same manipulation as in the previous solution: 

$$e_n = -n \left(
	\frac{c_n! - c_n}{3} - 1
\right)$$
"""

# ╔═╡ 3f4aa669-c23c-4db6-9eaf-3f6960260d86
function s(n::Integer)
	if n < 0 # Not a definition, just an implementation optimization!
		0
	else
		a = 2*n - 7
		r = 3 * (abs(a)/a + 1) ÷ 2 + s(n - 3)
		round(Int, r)
	end
end

# ╔═╡ fb7f0d08-f911-41ac-b628-c8754b1da3df
function e(n::Integer)
	c = n - s(n)
	-n * ((factorial(c)- c) ÷ 3 - 1)
end

# ╔═╡ 2dde6e60-89a2-44e8-a03d-46861a78a72e
recurse = [e(n) for n in 1:20]

# ╔═╡ ecb6a3f0-9177-4c4e-baae-2746b7ab3f9f
const τ = 2 * π

# ╔═╡ b699514c-2bc4-45dd-8814-b96beb181984
function a(n::Integer)
	sine = sin(n * τ / 3)
	switch = (sine * 2/sqrt(3))^2
	
	# We round it becuase it's inexact and we have something like 2.39e-31
	switch = round(Int, switch) 
	
	r = n * switch
end

# ╔═╡ 794a27af-6bf7-4ea7-b913-32b0fabc9c9b
sines = [a(n) for n in 1:20]

# ╔═╡ 41ba0028-3f91-4695-8c5e-89283e03aa66
function b(n::Integer)
	sine = ℯ^(im * n * τ / 3)
	switch = round(Int, imag(sine) * 2/sqrt(3)) ^ 2
	r = n * switch
end

# ╔═╡ 4dc4a23e-e8cb-4bc9-b70f-37a5ff4192b5
complex = [b(n) for n in 1:20]

# ╔═╡ 32208c9d-b713-45ba-8fb2-039edf1ed333
@assert(sines == complex == product == subtract == recurse)

# ╔═╡ f8d4e9e3-9b95-49e1-a467-35efa7688d06
TableOfContents()

# ╔═╡ b4fc3f8d-2316-4b51-87d7-ecb1c21974c9
spacer = html"<br><br><br>"

# ╔═╡ c033f642-d767-11ec-2504-c5ef2d0d844b
md"""
# Sucesiones!

My 2019 attempt to make a series that has $0$ every third element and $n$ otherwise

$spacer
"""

# ╔═╡ 012086b5-52f0-4078-b6f4-05f7ae411b2d
md"""
$spacer
## Appendix
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Memoize = "c03570c3-d221-55d1-a50c-7939bbd78826"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Memoize = "~0.4.4"
PlutoUI = "~0.7.39"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-DEV.1456"
manifest_format = "2.0"
project_hash = "545624ef689da1d90578048054e4f2249f0a96eb"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "a985dc37e357a3b22b260a5def99f3530fb415d3"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.2"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.0+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.73.0+4"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.9.1+2"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.24.0+2"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2020.7.22"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.17+2"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.0.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.41.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "16.2.1+1"
"""

# ╔═╡ Cell order:
# ╟─c033f642-d767-11ec-2504-c5ef2d0d844b
# ╟─6c214774-23ca-4159-9796-28c322b0c91b
# ╠═b699514c-2bc4-45dd-8814-b96beb181984
# ╟─794a27af-6bf7-4ea7-b913-32b0fabc9c9b
# ╟─38302ed6-6bbb-4c19-8ae9-802b880497c0
# ╟─5862bfb5-b6ac-409f-a9cd-24fa6ac13861
# ╠═41ba0028-3f91-4695-8c5e-89283e03aa66
# ╟─4dc4a23e-e8cb-4bc9-b70f-37a5ff4192b5
# ╟─95cea978-dfed-4212-8ed9-450d42303ac9
# ╟─9a008407-cb25-42da-8855-45e79e1693cc
# ╠═b50e5882-11dc-4da3-a408-41f070189ef8
# ╟─7986eebe-6a51-4d85-93f8-4e9c4812c4e0
# ╟─ca4207ca-70c3-46ce-9ce7-0f1e74e5885e
# ╟─f8a8a4a6-da5e-44fa-926a-da697da021e3
# ╠═b2427cde-9b92-4ed2-8900-926120ae8857
# ╟─9ef70702-df81-417c-ad5f-67ce79edf00d
# ╟─3f1cf7c4-d1c4-4520-9408-bb2e2d1704af
# ╟─14adddd6-ba2f-43eb-8e1e-2ce2303c5d96
# ╠═fb7f0d08-f911-41ac-b628-c8754b1da3df
# ╠═3f4aa669-c23c-4db6-9eaf-3f6960260d86
# ╟─2dde6e60-89a2-44e8-a03d-46861a78a72e
# ╠═32208c9d-b713-45ba-8fb2-039edf1ed333
# ╟─012086b5-52f0-4078-b6f4-05f7ae411b2d
# ╟─ecb6a3f0-9177-4c4e-baae-2746b7ab3f9f
# ╟─ee6af700-2e4f-48fb-b364-d16240675b7a
# ╟─db76cd30-4697-4185-b6b2-7e587ccd970e
# ╟─f8d4e9e3-9b95-49e1-a467-35efa7688d06
# ╟─b4fc3f8d-2316-4b51-87d7-ecb1c21974c9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
