#import "template.typ": *

= Chap. 1 - Complex Numbers

== 1.1 Definitions and Algebraic Properties

신은 자연수를 만들었고 나머지는 모두 인간의 창조물이다. - 크로네커.

복소수는 실수에서 확장되었고 실수와 비슷한 면이 있다. 가장 중요한 면은 실수의 뭔가를 연결할 때
복소수를 사용할 수 있다는 점이다. 3차 방정식이 그렇고 적분 일부가 그렇고 Fourier 해석도 그렇다.

#d-definition(
  "복소수 (Complex Numbers)",
  [
    복소수 집합 $CC = {x + i y : x, y in RR}$ ($i^2 = -1$).
    $z = x + i y$ 에 대하여 $x$를 실수부($text("Re")(z)$), $y$를 허수부($text("Im")(z)$)라 한다.

    덧셈:
    $ (x, y) + (a, b) := (x+a, y+b) $

    곱셈:
    $ (x, y) dot (a, b) := (x a - y b, x b + y a) $
  ],
  intuition: [
    복소수를 해석하는 방법은 여러 가지. 실수의 대수적 확장, 기하학적 확장, 해석적 확장.
  ],
)

위의 덧셈과 곱셈의 정의로 $CC$는 $RR$처럼 필드(체)가 된다.

#d-theorem("복소수 체 - Complex Number Field")[
  - +에 대한 가환 그룹
  - $dot$에 대한 가환 그룹
  - +와 $dot$ 간의 배분 법칙
]

위는 대수적 정의이다. 대수 정의도 $i^2 = -1$에서 수학적으로 엄밀하게 정의하려면
다항식 환(Polynomial Ring)을 이데알(Ideal)로 자르는 몫환(Quotient Ring) 개념을
쓰는 것이라고 한다.
$ CC := RR[x]/(x^2 + 1) $

이는 현대대수학의 가장 앞선 개념인 이데알과 몫 공간을 사용하여 정의하므로
현재 수준에서 도입하기는 어려움이 있다. 나중에 공부할 것이다.

#d-theorem("Fundamental Theorem of Algebra")[
  상수가 아닌 모든 복소다항식은 복소수 근을 적어도 하나 갖는다.
]

지금 공부하는 책에서 증명한다. 여러 가지 증명 방법이 있는 것으로 안다. 좋은 문제는
한번만 풀리지 않는다는 원리에 따라 이 정리도 좋은 문제가 될 필요조건을 갖고 있다.

== 1.2 From Algebra to Geometry and Back

복소평면이 도입된 후 복소해석학은 비약적인 발전이 있었던 것으로 알고 있다. 복소해석학은
기하학적이다는 말도 있다. 아직 충분히 음미할 수준은 못 된다. 복소기하학도 중요한
수학의 연구 분야이므로 매우 풍부하고 여러 분야를 통합할 수 있는 능력이 있나 보다.

실수축과 허수축에 순서쌍을 표시한다는 간단한 아이디어로 시작한다. 이후 복소수의 곱셈은
회전과 확대/축소(scaling)에 해당한다는 것을 알게 된다. 이것이 생각보다 중요하게
작용하는 것으로 이해했다.

#d-definition("absolute value or modulus")[
  The absolute value (also called the modules) of $z = x + i y$ is $ r = |z| := sqrt(x^2 + y^2) $
  and an argument of $z = x + i y$ is a number $phi in RR$ such that $ x = r cos phi, y = r sin phi. $
]

고등학교에서 배웠던 내용과 같다.

복소수의 위상은 $RR^2$와 같다. 특히, modulus를 norm으로 하고 여기서 유도된 거리를 사용한
거리 공간으로서 같다. 하지만 미분은 필드의 몫으로 정의한다.

#d-theorem("metric, distance")[
  Let $z_1, z_2 in CC$. Let $d(z_1, z_2)$ denote the distance between the two vectors in $RR^2$.
  Then $ d(z_1, z_2) = |z_1 - z_2| = |z_2 - z_1| . $
]

#d-definition("e의 정의")[
  $ e^(i phi) := cos phi + i sin phi $
]

여기서는 본격적인 함수가 아닌 간편한 표기법으로 도입한다.

#d-theorem("e의 성질")[
  (a) $e^(i phi_1) e^(i phi_2) = e^(i (phi_1 + phi_2))$

  (b) $e^(i 0) = 1$

  (c) $1 / e^(i phi) = e^(-i phi)$

  (d) $e^(i ( phi + 2 pi)) = e^(i phi)$

  (e) $|e^(i phi)| = 1$

  (f) $d/(d phi) e^(i phi) = i e^( i phi )$
]

이 책의 설명은 정확하게 linear 하게 진행되지 않는다. first course라 조망을 포함하고
강의하는 사람에게 의지하는 듯 하다. 그래도, 좋은 책이다.

#d-definition("root of unity")[
  A root of unity is a complex number $zeta$ such that $zeta^n = 1$.
]

복소수의 곱이 회전의 성질을 갖고 있어 흥미로운 구조인 단위 근이 만들어진다.

$x + i y = r e^(i phi)$ 형태로 나타낼 수 있다.여러 곳에서 매우 유용하게 사용하는 복소수 성질을
잘 반영하는 표기법이다.

이제 다섯 가지 형태로 복소수를 표기할 수 있다.
- the formal definition
- rectangular form
- polar form
- geometrically (using cartesian coordinates)
- geometrically (using polar coordinates)

$x + i y = r e^(i phi) = r(cos phi + i sin phi)$ 에 모든 것이 들어있다. 이를 기하적으로 대수적으로 해석할 수 있다.

== 1.3 Geometric Properties

#d-definition("complex conjugate")[
  The number $x - i y$ is the conjugate of $x + i y$. We denote the conjugate by
  $ overline(x + i y) := x - i y . $

]

#d-theorem("complex conjugate properties")[
  $z_1, z_2, z in CC$,

  (a) $overline(z_1 plus.minus z_2) = overline(z_1) plus.minus overline(z_2)$

  (b) $overline(z_1 dot z_2) = overline(z_1) dot overline(z_2)$

  (c) $overline(z_1 / z_2) = overline(z_1) / overline(z_2)$

  (d) $overline(overline(z)) = z$

  (e) $|overline(z)| = |z|$

  (f) $|z|^2 = z overline(z)$

  (g) $Re(z) = 1/2 (z + overline(z))$

  (h) $Im(z) = 1/(2i)(z - overline(z))$

  (i) $overline(e^(i phi)) = e^(-i phi)$
]

#d-theorem("triangle inequality")[
  For any $z_1, z_2 in CC$, we have $|z_1 + z_2| lt.eq |z_1| + |z_2|$.
]

#d-theorem("다른 성질들")[
  $z_1, z_2, ..., z_n in CC$.

  (a) $|plus.minus z_1 plus.minus z_2| lt.eq |z_1| + |z_2|$

  (b) $|plus.minus z_1 plus.minus z_2| gt.eq ||z_1| - |z_2||$

  (c) $|sum_(k=1)^n z_k| lt.eq sum_(k=1)^n |z_k|$
]

== 1.4 Elementary Topology of the Plane

#d-definition("circle and disk")[
  $C[a, r] := { z in CC : |z - a| = r}$.

  $D[a, r] := [z in CC : |z -a| lt r]$.
]

#d-definition("topology")[
  Suppose $G$ is a subset of $CC$.

  (a) An interior point

  (b) A boundary point

  (c) An accumulation point

  (d) An isolated point
]

여기서 interior, boundary를 같이 정의.
#d-definition("open set, closed set")[
  A set is open if all its points are interior points. A set is closed if it contains
  all its boundary points.
]

#d-definition("boundary notation, interior, clouse")[
  The *boundary* $partial G$ of a set $G$ is the set of all boundary points of $G$.

  The *interior* of $G$ is the set of all interior points of $G$.

  The *closure* of $G$ is the set $G union partial G$.
]

#d-definition("bounded")[
  The set $G$ is bounded if $G in D[0, r]$ for some $r gt 0$.
]

#d-definition("separated, connected")[
  Two sets $X, Y in CC$ are *separated* if there are disjoint open sets $A, B in CC$ so that
  $X in A$ and $Y in B$.

  A set $G in CC$ is *connected* if it is impossible to find two separated sets whose union is $G$.

  A *region* is a connected open set.
]

#d-definition("path, curve")[
  A *path (or curve)* in $CC$ is a continuous function $gamma : [a, b] arrow.r CC$,
  where $[a, b]$ is a closed interval in $RR$. We may think of $gamma$ as a parameterization of
  the image that is painted by the path and will often write this parameterization as
  $gamma (t), a lt.eq t lt.eq b$. The path is *smooth* if $gamma$ is differentiable and its derivative
  $gamma'$ is continuous and nonzero.
]

위에서 $gamma$는 복소 함수이다. 미분을 극한을 정의하기 전에 쓰고 있다. 직관적으로
거리 공간으로 보면 되고, 실수부와 허수부가 각각 극한을 가지면 수렴한다.

복소수 적분이 경로 적분이기 때문에 경로는 자주 나온다. 또 원이 축약 가능한지에 따라 여러
성질이 다르게 나타나기 때문에 원의 경로도 많이 다루게 된다.

#d-definition("simple path")[

]

= Chap. 2 - Examples of Functions

내게 수학은 예시들이다. 이론은 예시를 분류하기위해 필요하다. - John B. Conway

== 3.1 Mobius Transformations

#definition("3.1.1 linear fractional transformation")[
  A linear fractional transformation is a function of the form
  $ f(z) = (a z + b) / (c z + d) $
  where $a, b, c, d in CC$.
  If $a d - b c eq.not 0$, then $f$ is a Mobius transformation.
]

지극히 단순해 보이는 이런 변환이 복소수에서는 풍부한 기하학적 성질을 갖는다.

#idea("뫼비우스 변환의 조건")[
  $a d - b c eq.not 0$는 여러 곳에서 쓰인다.

  - injective 하다는 조건
  - 미분 값이 0이 아니라는 조건
]

#theorem("3.1.2 the inverse of Mobius transformation")[
  Let $a, b, c, d in CC$ with $c eq.not 0$. Then the Mobius transformation
  $f: CC\\{-d/c} arrow CC \\ {a/c}$
  given by $f(z) = (a z + b) / ( c z + d)$ has the inverse function
  $f^(-1): CC \\ {a/c} arrow CC \\ {-d/c}$ given by
  $ f^(-1) = (d z - b) / (-c z + a) . $
]

#idea("연습 - 위의 증명")[
  - [1] injective를 보임
  - [2] 역함수가 있음
    - surjective 조건이 보완됨
]

#theorem("3.1.4 변환의 형태")[
  $f(z) = (a z + b ) / (c z + d)$ 일 때, $c eq.not 0$ 라면
  $ f(z) = (b c - a d) / (c^2) 1 / (z + d/c) + a/c $
  이다.
]

#idea("질문")[
  Q. $c eq 0$ 일 때는 ?

  Q. 이동, 확대(dilations), 역전(inversion)은 무엇인가?
]

#theorem("3.1.5 뫼비우스 변환 특성")[
  뫼비우스 변환은 원과 직선을 원 또는 직선으로 변환한다.
]

#proof[
  - 원과 직선을 통합하는 이차식으로 표시
  - $u + i v = (x - i y)/(x^2 + y^2)$로 위의 이차식을 변형

  원과 직선을 표현하는 이차식은 이차곡선 중의 하나이다. 처음에 이렇게 접근하기가 어렵다.
]

#example("3.1.6과 추가 예시")[
  1)  $f(z) = (z - 1) / (i z + i)$ 가 단위원을 직선으로 보낸다.

  2) $f(z) = 1/z$ 는 $Re(z) = x_0$ 인 직선을 $1/(2x_0)$ 반지름에 $(1/(2x_0), 0)$에 중심을
  둔 원으로 보낸다.

  둘 다 어떻게 확인할까? 직관적이고 쉬운 방법은? 3.1.5의 증명에 쓰인 아이디어도 유용하다.
]

== 3.2 Infinity and the Cross Ratio

#definition("3.2.1")[
  $f: G arrow CC$ 함수의으 발산 정의를 한다. $z arrow z_0, z arrow oo$일 경우 실수와 비슷하게 정의한다.
]

#example("3.2.2")[
  $ lim_(z arrow 0) 1/(z^2) $

  어디로 가는가? 적절한 정의에 따라 확인.
]

#example("3.2.3")[
  $ f(z) = (a z + b) / (c z + d) $ 일 때,
  $ lim_(z arrow oo) f(z) $

  이건 어떻게 될까? 주어진 $epsilon gt 0$에 대해 $|z| gt N$일 때 수렴하는 값과 차이가
  $epsilon$보다 작아지는 $N$ 값을 찾아야 한다.
]

#definition("3.2.4")[
  확장 복소 평면 $hat(CC) := CC union {oo}$은 다음 조건을 만족한다.

  $(a) ~ (e)$까지 조건들이 있다. lim을 통합하는 것이 목적이라
  필요한 극한 형태들을 포함한다.
]

#theorem("3.2.5")[
  $hat(CC)$에서 뫼비우스 변환이 전체 공간으로 확장될 수 있다.

  어떻게 확장할 수 있는가? $oo$를 포함한다는 점과 3.2.4의 정의를 활용한다.
]

#idea("뫼비우스 변환의 확장")[
  any Mobius transformation of $hat(CC)$ transforms circles to circles.

  라인을 $oo$를 지나는 원으로 생각하면 리만 구 상의 원으로 볼 수 있다.
]

#definition("3.2.8")[
  $[z, z_1, z_2, z_3] := ((z-z_1)(z_2-z_3)) / ((z - z_3)(z_2 - z_1))$

  $z_1 arrow 0, z_2 arrow 1, z_3 arrow oo$로 변환하는 뫼비우스 변환이다.
]

#example("3.2.9")[
  $ f(z) = (z-1) / (i z + i) $

  위 변환은 cross ratio 변환이다.
]

#theorem("3.2.10")[
  cross ratio 변환은 뫼비우스 변환으로 $f(z_1) = 0, f(z_2) = 1, f(z_3) = oo$이고,
  $g(z_1) = 0, g(z_2) = 1, g(z_3) = oo$인 또 다른 뫼비우스 변환이 있다면 $f$와 같다.
  (같은 함수 값을 갖는 변환은 고유하다)
]

이와 같은 전개에서 무엇을 이해한 것이어야 할까?

#theorem("3.2.11")[
  $z_1, z_2, z_3$와 $w_1, w_2, w_3$가 각각 다른 $hat(CC)$의 점일 때, $h(z_1) = w_1, h(z_2) = w_2, h(z_3) = w_3$를 만족하는 고유한 뫼비우스 변환 $h$가 있다.
]
#proof[
  - cross ratio $f(z) = [z, z_1, z_2, z_3]$와 $g(z) = [z, w_1, w_2, w_3]$를 살펴본다.
  - $h = g^(-1) comp f$
]

$oo$의 도입은 리만 구면으로 나아가는 첫 단계이다. cross ratio 변환은 3.2.11의 결과와 같이
세점이 주어지면 확정되는 뫼비우스 변환을 찾기위한 것이다.

무엇을 기억할 것인가? 무엇을 알아야 이해했다고 할 수 있나? 어디에 쓸 것인가?
다음 단계는 무엇일까? 어느 시절에 고민했던 내용일까?



== 3.3 Stereographic Projection

$oo$의 추가로 복소 평면에 유용한 구조가 생긴다. stereographic projection이라는
복소 평면을 구면으로 매핑하는 함수 형태의 투영이 가능하게 된다. 구면은 원점에
중심을 두고 (0, 0, 1)에서 x-y 평면(복소 평면)에 선을 그어서 점들을 연결한다.
이렇게 보면 복소 평면의 직선은 구면 상의 원이 된다.

#idea("시각화")[
  입체 투영을 구면 상의 원들이 복소 평면에서 직선이나 원으로 변하는 것을 볼 수 있도록
  manim으로 시각화 한다.
]

#theorem("3.3.3")[
  $phi : SS^2 arrow CC$는 구면 상의 점을 (0, 0, 1)에서 복소평면으로 매핑한다.
  $phi^(-1)$도 구할 수 있다.

  $phi$와 $phi^(-1)$를 계산한다.
]

#idea("3.3.3의 계산")[
  - 직선의 방정식으로 $phi$가 투영하는 좌표를 계산할 수 있다.
  - 이 좌표값과 구면의 방정식으로 $phi^(-1)$를 계산할 수 있다.
]

#theorem("3.3.4")[
  stereographic projection이 구면 상의 원을 복소평면 상의 원이나 직선으로 옮긴다.
  구면 상의 원이 N (0, 0, 1)을 포함할 때만 직선이 된다 (iff 이다)
]

#proof[
  증명은 구면 상의 원이 평면 H와 구면이 만나는 것으로 정해진다는 아이디어에서 시작한다.
  $H = {(x, y, z) in RR^3 : (x, y, z) dot (x_0, y_0, z_0) = k }$

  Q. $H inter SS^2$가 정말 원인가? 기하학적인 직관의 대수적 확인은 필요하다.

  이후 전개는 $phi^(-1)$의 좌표값 계산을 하는 3.3.3을 활용한다.
]

이제 복소평면을 리만 구로 입체 투영을 통해 생각할 수 있다. 기하적인 실험 공간이 된다.

#idea("리만 구면의 변환")[
  It is worth thinking about, though beyond the scope of this book, how other
  Mobius functions behave. For instance, a rotation $f(z) = e^(i theta) z$,
  composed with $phi^(-1)$, can be seen to be a rotation of $SS^2$.

  We encourage you to verify this and consider the harder problems of visualizaing
  a real dilation, $f(z) = r z$, or a translation, $f(z) = z + b$.

  We give the hint that a real dilation is in some sense dual to a rotation, in that
  each moves points along perpendicular sets of circles. Translations can also
  be visualized via how they move points along sets of circles.

  책의 범위를 벗어나는 생각해 볼 과제로 주고 있다. 변환을 리만 구면의 변환으로
  생각하는 연습은 좋은 기하학적 훈련이다.
]

위 과제 다음에 직접 $f(z) = 1/z$의 inversion을 구면의 변환으로 설명하는 계산이
나온다. 기하적인 직관을 대수로 확인하는 과정이다. 또는 대수의 계산을 기하적인
직관으로 쌓는다. 그림이 그려지는가?

거리를 $SS^2$에 복소 공간에 맞춰서 줄 수 있다. 전개해 나갈 수는 있지만 아직
역량이 안 된다. 필요를 모르기도 하고 충분한 경험이 없기 때문이다.


== Exponential and trigonometric functions

#definition("3.4.1")[
  $exp(z) := e^x (cos y + i sin y) = e^x e^(i y)$

]

#theorem("3.4.2")[
  (a) 곱하기와 더하기

  (b) 역수

  (c) 주기 $2 pi i$

  (d) 절대값 (modulus)

  (e) 양수

  (f) 미분
]




