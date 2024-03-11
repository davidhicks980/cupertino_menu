function _F_toggles_initialize(a) {
    ("undefined" !== typeof globalThis ? globalThis : "undefined" !== typeof self ? self : this)._F_toggles = a || []
}
_F_toggles_initialize([]);
function n() {
    return function() {}
}
function q(a) {
    return function() {
        return this[a]
    }
}
function aa(a) {
    return function() {
        return a
    }
}
var v;
function ba(a) {
    var c = 0;
    return function() {
        return c < a.length ? {
            done: !1,
            value: a[c++]
        } : {
            done: !0
        }
    }
}
var ca = "function" == typeof Object.defineProperties ? Object.defineProperty : function(a, c, d) {
    if (a == Array.prototype || a == Object.prototype)
        return a;
    a[c] = d.value;
    return a
}
;
function da(a) {
    a = ["object" == typeof globalThis && globalThis, a, "object" == typeof window && window, "object" == typeof self && self, "object" == typeof global && global];
    for (var c = 0; c < a.length; ++c) {
        var d = a[c];
        if (d && d.Math == Math)
            return d
    }
    throw Error("a");
}
var ea = da(this);
function x(a, c) {
    if (c)
        a: {
            var d = ea;
            a = a.split(".");
            for (var e = 0; e < a.length - 1; e++) {
                var f = a[e];
                if (!(f in d))
                    break a;
                d = d[f]
            }
            a = a[a.length - 1];
            e = d[a];
            c = c(e);
            c != e && null != c && ca(d, a, {
                configurable: !0,
                writable: !0,
                value: c
            })
        }
}
x("Symbol", function(a) {
    function c(g) {
        if (this instanceof c)
            throw new TypeError("b");
        return new d(e + (g || "") + "_" + f++,g)
    }
    function d(g, h) {
        this.g = g;
        ca(this, "description", {
            configurable: !0,
            writable: !0,
            value: h
        })
    }
    if (a)
        return a;
    d.prototype.toString = q("g");
    var e = "jscomp_symbol_" + (1E9 * Math.random() >>> 0) + "_"
      , f = 0;
    return c
});
x("Symbol.iterator", function(a) {
    if (a)
        return a;
    a = Symbol("c");
    for (var c = "Array Int8Array Uint8Array Uint8ClampedArray Int16Array Uint16Array Int32Array Uint32Array Float32Array Float64Array".split(" "), d = 0; d < c.length; d++) {
        var e = ea[c[d]];
        "function" === typeof e && "function" != typeof e.prototype[a] && ca(e.prototype, a, {
            configurable: !0,
            writable: !0,
            value: function() {
                return fa(ba(this))
            }
        })
    }
    return a
});
function fa(a) {
    a = {
        next: a
    };
    a[Symbol.iterator] = function() {
        return this
    }
    ;
    return a
}
function ha(a) {
    var c = "undefined" != typeof Symbol && Symbol.iterator && a[Symbol.iterator];
    if (c)
        return c.call(a);
    if ("number" == typeof a.length)
        return {
            next: ba(a)
        };
    throw Error("d`" + String(a));
}
function ia(a) {
    for (var c, d = []; !(c = a.next()).done; )
        d.push(c.value);
    return d
}
function ja(a) {
    return a instanceof Array ? a : ia(ha(a))
}
var ka = "function" == typeof Object.create ? Object.create : function(a) {
    function c() {}
    c.prototype = a;
    return new c
}
, la;
if ("function" == typeof Object.setPrototypeOf)
    la = Object.setPrototypeOf;
else {
    var ma;
    a: {
        var na = {
            a: !0
        }
          , oa = {};
        try {
            oa.__proto__ = na;
            ma = oa.a;
            break a
        } catch (a) {}
        ma = !1
    }
    la = ma ? function(a, c) {
        a.__proto__ = c;
        if (a.__proto__ !== c)
            throw new TypeError("e`" + a);
        return a
    }
    : null
}
var pa = la;
function y(a, c) {
    a.prototype = ka(c.prototype);
    a.prototype.constructor = a;
    if (pa)
        pa(a, c);
    else
        for (var d in c)
            if ("prototype" != d)
                if (Object.defineProperties) {
                    var e = Object.getOwnPropertyDescriptor(c, d);
                    e && Object.defineProperty(a, d, e)
                } else
                    a[d] = c[d];
    a.ua = c.prototype
}
function qa() {
    for (var a = Number(this), c = [], d = a; d < arguments.length; d++)
        c[d - a] = arguments[d];
    return c
}
x("Promise", function(a) {
    function c(h) {
        this.g = 0;
        this.o = void 0;
        this.j = [];
        this.B = !1;
        var k = this.v();
        try {
            h(k.resolve, k.reject)
        } catch (l) {
            k.reject(l)
        }
    }
    function d() {
        this.g = null
    }
    function e(h) {
        return h instanceof c ? h : new c(function(k) {
            k(h)
        }
        )
    }
    if (a)
        return a;
    d.prototype.j = function(h) {
        if (null == this.g) {
            this.g = [];
            var k = this;
            this.o(function() {
                k.A()
            })
        }
        this.g.push(h)
    }
    ;
    var f = ea.setTimeout;
    d.prototype.o = function(h) {
        f(h, 0)
    }
    ;
    d.prototype.A = function() {
        for (; this.g && this.g.length; ) {
            var h = this.g;
            this.g = [];
            for (var k = 0; k < h.length; ++k) {
                var l = h[k];
                h[k] = null;
                try {
                    l()
                } catch (m) {
                    this.v(m)
                }
            }
        }
        this.g = null
    }
    ;
    d.prototype.v = function(h) {
        this.o(function() {
            throw h;
        })
    }
    ;
    c.prototype.v = function() {
        function h(m) {
            return function(p) {
                l || (l = !0,
                m.call(k, p))
            }
        }
        var k = this
          , l = !1;
        return {
            resolve: h(this.I),
            reject: h(this.A)
        }
    }
    ;
    c.prototype.I = function(h) {
        if (h === this)
            this.A(new TypeError("f"));
        else if (h instanceof c)
            this.M(h);
        else {
            a: switch (typeof h) {
            case "object":
                var k = null != h;
                break a;
            case "function":
                k = !0;
                break a;
            default:
                k = !1
            }
            k ? this.H(h) : this.C(h)
        }
    }
    ;
    c.prototype.H = function(h) {
        var k = void 0;
        try {
            k = h.then
        } catch (l) {
            this.A(l);
            return
        }
        "function" == typeof k ? this.O(k, h) : this.C(h)
    }
    ;
    c.prototype.A = function(h) {
        this.D(2, h)
    }
    ;
    c.prototype.C = function(h) {
        this.D(1, h)
    }
    ;
    c.prototype.D = function(h, k) {
        if (0 != this.g)
            throw Error("g`" + h + "`" + k + "`" + this.g);
        this.g = h;
        this.o = k;
        2 === this.g && this.J();
        this.L()
    }
    ;
    c.prototype.J = function() {
        var h = this;
        f(function() {
            if (h.F()) {
                var k = ea.console;
                "undefined" !== typeof k && k.error(h.o)
            }
        }, 1)
    }
    ;
    c.prototype.F = function() {
        if (this.B)
            return !1;
        var h = ea.CustomEvent
          , k = ea.Event
          , l = ea.dispatchEvent;
        if ("undefined" === typeof l)
            return !0;
        "function" === typeof h ? h = new h("unhandledrejection",{
            cancelable: !0
        }) : "function" === typeof k ? h = new k("unhandledrejection",{
            cancelable: !0
        }) : (h = ea.document.createEvent("CustomEvent"),
        h.initCustomEvent("unhandledrejection", !1, !0, h));
        h.promise = this;
        h.reason = this.o;
        return l(h)
    }
    ;
    c.prototype.L = function() {
        if (null != this.j) {
            for (var h = 0; h < this.j.length; ++h)
                g.j(this.j[h]);
            this.j = null
        }
    }
    ;
    var g = new d;
    c.prototype.M = function(h) {
        var k = this.v();
        h.Cb(k.resolve, k.reject)
    }
    ;
    c.prototype.O = function(h, k) {
        var l = this.v();
        try {
            h.call(k, l.resolve, l.reject)
        } catch (m) {
            l.reject(m)
        }
    }
    ;
    c.prototype.then = function(h, k) {
        function l(u, w) {
            return "function" == typeof u ? function(F) {
                try {
                    m(u(F))
                } catch (L) {
                    p(L)
                }
            }
            : w
        }
        var m, p, r = new c(function(u, w) {
            m = u;
            p = w
        }
        );
        this.Cb(l(h, m), l(k, p));
        return r
    }
    ;
    c.prototype.catch = function(h) {
        return this.then(void 0, h)
    }
    ;
    c.prototype.Cb = function(h, k) {
        function l() {
            switch (m.g) {
            case 1:
                h(m.o);
                break;
            case 2:
                k(m.o);
                break;
            default:
                throw Error("h`" + m.g);
            }
        }
        var m = this;
        null == this.j ? g.j(l) : this.j.push(l);
        this.B = !0
    }
    ;
    c.resolve = e;
    c.reject = function(h) {
        return new c(function(k, l) {
            l(h)
        }
        )
    }
    ;
    c.race = function(h) {
        return new c(function(k, l) {
            for (var m = ha(h), p = m.next(); !p.done; p = m.next())
                e(p.value).Cb(k, l)
        }
        )
    }
    ;
    c.all = function(h) {
        var k = ha(h)
          , l = k.next();
        return l.done ? e([]) : new c(function(m, p) {
            function r(F) {
                return function(L) {
                    u[F] = L;
                    w--;
                    0 == w && m(u)
                }
            }
            var u = []
              , w = 0;
            do
                u.push(void 0),
                w++,
                e(l.value).Cb(r(u.length - 1), p),
                l = k.next();
            while (!l.done)
        }
        )
    }
    ;
    return c
});
function sa(a, c, d) {
    if (null == a)
        throw new TypeError("i`" + d);
    if (c instanceof RegExp)
        throw new TypeError("j`" + d);
    return a + ""
}
x("String.prototype.startsWith", function(a) {
    return a ? a : function(c, d) {
        var e = sa(this, c, "startsWith")
          , f = e.length
          , g = c.length;
        d = Math.max(0, Math.min(d | 0, e.length));
        for (var h = 0; h < g && d < f; )
            if (e[d++] != c[h++])
                return !1;
        return h >= g
    }
});
x("globalThis", function(a) {
    return a || ea
});
function ta(a, c) {
    a instanceof String && (a += "");
    var d = 0
      , e = !1
      , f = {
        next: function() {
            if (!e && d < a.length) {
                var g = d++;
                return {
                    value: c(g, a[g]),
                    done: !1
                }
            }
            e = !0;
            return {
                done: !0,
                value: void 0
            }
        }
    };
    f[Symbol.iterator] = function() {
        return f
    }
    ;
    return f
}
x("Array.prototype.values", function(a) {
    return a ? a : function() {
        return ta(this, function(c, d) {
            return d
        })
    }
});
x("Object.is", function(a) {
    return a ? a : function(c, d) {
        return c === d ? 0 !== c || 1 / c === 1 / d : c !== c && d !== d
    }
});
x("Math.imul", function(a) {
    return a ? a : function(c, d) {
        c = Number(c);
        d = Number(d);
        var e = c & 65535
          , f = d & 65535;
        return e * f + ((c >>> 16 & 65535) * f + e * (d >>> 16 & 65535) << 16 >>> 0) | 0
    }
});
x("Array.prototype.entries", function(a) {
    return a ? a : function() {
        return ta(this, function(c, d) {
            return [c, d]
        })
    }
});
function ua(a, c) {
    return Object.prototype.hasOwnProperty.call(a, c)
}
x("WeakMap", function(a) {
    function c(l) {
        this.g = (k += Math.random() + 1).toString();
        if (l) {
            l = ha(l);
            for (var m; !(m = l.next()).done; )
                m = m.value,
                this.set(m[0], m[1])
        }
    }
    function d() {}
    function e(l) {
        var m = typeof l;
        return "object" === m && null !== l || "function" === m
    }
    function f(l) {
        if (!ua(l, h)) {
            var m = new d;
            ca(l, h, {
                value: m
            })
        }
    }
    function g(l) {
        var m = Object[l];
        m && (Object[l] = function(p) {
            if (p instanceof d)
                return p;
            Object.isExtensible(p) && f(p);
            return m(p)
        }
        )
    }
    if (function() {
        if (!a || !Object.seal)
            return !1;
        try {
            var l = Object.seal({})
              , m = Object.seal({})
              , p = new a([[l, 2], [m, 3]]);
            if (2 != p.get(l) || 3 != p.get(m))
                return !1;
            p.delete(l);
            p.set(m, 4);
            return !p.has(l) && 4 == p.get(m)
        } catch (r) {
            return !1
        }
    }())
        return a;
    var h = "$jscomp_hidden_" + Math.random();
    g("freeze");
    g("preventExtensions");
    g("seal");
    var k = 0;
    c.prototype.set = function(l, m) {
        if (!e(l))
            throw Error("k");
        f(l);
        if (!ua(l, h))
            throw Error("l`" + l);
        l[h][this.g] = m;
        return this
    }
    ;
    c.prototype.get = function(l) {
        return e(l) && ua(l, h) ? l[h][this.g] : void 0
    }
    ;
    c.prototype.has = function(l) {
        return e(l) && ua(l, h) && ua(l[h], this.g)
    }
    ;
    c.prototype.delete = function(l) {
        return e(l) && ua(l, h) && ua(l[h], this.g) ? delete l[h][this.g] : !1
    }
    ;
    return c
});
x("Map", function(a) {
    function c() {
        var k = {};
        return k.Da = k.next = k.head = k
    }
    function d(k, l) {
        var m = k[1];
        return fa(function() {
            if (m) {
                for (; m.head != k[1]; )
                    m = m.Da;
                for (; m.next != m.head; )
                    return m = m.next,
                    {
                        done: !1,
                        value: l(m)
                    };
                m = null
            }
            return {
                done: !0,
                value: void 0
            }
        })
    }
    function e(k, l) {
        var m = l && typeof l;
        "object" == m || "function" == m ? g.has(l) ? m = g.get(l) : (m = "" + ++h,
        g.set(l, m)) : m = "p_" + l;
        var p = k[0][m];
        if (p && ua(k[0], m))
            for (k = 0; k < p.length; k++) {
                var r = p[k];
                if (l !== l && r.key !== r.key || l === r.key)
                    return {
                        id: m,
                        list: p,
                        index: k,
                        ma: r
                    }
            }
        return {
            id: m,
            list: p,
            index: -1,
            ma: void 0
        }
    }
    function f(k) {
        this[0] = {};
        this[1] = c();
        this.size = 0;
        if (k) {
            k = ha(k);
            for (var l; !(l = k.next()).done; )
                l = l.value,
                this.set(l[0], l[1])
        }
    }
    if (function() {
        if (!a || "function" != typeof a || !a.prototype.entries || "function" != typeof Object.seal)
            return !1;
        try {
            var k = Object.seal({
                x: 4
            })
              , l = new a(ha([[k, "s"]]));
            if ("s" != l.get(k) || 1 != l.size || l.get({
                x: 4
            }) || l.set({
                x: 4
            }, "t") != l || 2 != l.size)
                return !1;
            var m = l.entries()
              , p = m.next();
            if (p.done || p.value[0] != k || "s" != p.value[1])
                return !1;
            p = m.next();
            return p.done || 4 != p.value[0].x || "t" != p.value[1] || !m.next().done ? !1 : !0
        } catch (r) {
            return !1
        }
    }())
        return a;
    var g = new WeakMap;
    f.prototype.set = function(k, l) {
        k = 0 === k ? 0 : k;
        var m = e(this, k);
        m.list || (m.list = this[0][m.id] = []);
        m.ma ? m.ma.value = l : (m.ma = {
            next: this[1],
            Da: this[1].Da,
            head: this[1],
            key: k,
            value: l
        },
        m.list.push(m.ma),
        this[1].Da.next = m.ma,
        this[1].Da = m.ma,
        this.size++);
        return this
    }
    ;
    f.prototype.delete = function(k) {
        k = e(this, k);
        return k.ma && k.list ? (k.list.splice(k.index, 1),
        k.list.length || delete this[0][k.id],
        k.ma.Da.next = k.ma.next,
        k.ma.next.Da = k.ma.Da,
        k.ma.head = null,
        this.size--,
        !0) : !1
    }
    ;
    f.prototype.clear = function() {
        this[0] = {};
        this[1] = this[1].Da = c();
        this.size = 0
    }
    ;
    f.prototype.has = function(k) {
        return !!e(this, k).ma
    }
    ;
    f.prototype.get = function(k) {
        return (k = e(this, k).ma) && k.value
    }
    ;
    f.prototype.entries = function() {
        return d(this, function(k) {
            return [k.key, k.value]
        })
    }
    ;
    f.prototype.keys = function() {
        return d(this, function(k) {
            return k.key
        })
    }
    ;
    f.prototype.values = function() {
        return d(this, function(k) {
            return k.value
        })
    }
    ;
    f.prototype.forEach = function(k, l) {
        for (var m = this.entries(), p; !(p = m.next()).done; )
            p = p.value,
            k.call(l, p[1], p[0], this)
    }
    ;
    f.prototype[Symbol.iterator] = f.prototype.entries;
    var h = 0;
    return f
});
x("String.fromCodePoint", function(a) {
    return a ? a : function(c) {
        for (var d = "", e = 0; e < arguments.length; e++) {
            var f = Number(arguments[e]);
            if (0 > f || 1114111 < f || f !== Math.floor(f))
                throw new RangeError("m`" + f);
            65535 >= f ? d += String.fromCharCode(f) : (f -= 65536,
            d += String.fromCharCode(f >>> 10 & 1023 | 55296),
            d += String.fromCharCode(f & 1023 | 56320))
        }
        return d
    }
});
x("Array.prototype.find", function(a) {
    return a ? a : function(c, d) {
        a: {
            var e = this;
            e instanceof String && (e = String(e));
            for (var f = e.length, g = 0; g < f; g++) {
                var h = e[g];
                if (c.call(d, h, g, e)) {
                    c = h;
                    break a
                }
            }
            c = void 0
        }
        return c
    }
});
x("Object.values", function(a) {
    return a ? a : function(c) {
        var d = [], e;
        for (e in c)
            ua(c, e) && d.push(c[e]);
        return d
    }
});
x("Array.prototype.includes", function(a) {
    return a ? a : function(c, d) {
        var e = this;
        e instanceof String && (e = String(e));
        var f = e.length;
        d = d || 0;
        for (0 > d && (d = Math.max(d + f, 0)); d < f; d++) {
            var g = e[d];
            if (g === c || Object.is(g, c))
                return !0
        }
        return !1
    }
});
x("String.prototype.includes", function(a) {
    return a ? a : function(c, d) {
        return -1 !== sa(this, c, "includes").indexOf(c, d || 0)
    }
});
x("Number.MAX_SAFE_INTEGER", aa(9007199254740991));
x("Number.isFinite", function(a) {
    return a ? a : function(c) {
        return "number" !== typeof c ? !1 : !isNaN(c) && Infinity !== c && -Infinity !== c
    }
});
x("Number.isInteger", function(a) {
    return a ? a : function(c) {
        return Number.isFinite(c) ? c === Math.floor(c) : !1
    }
});
x("Number.isSafeInteger", function(a) {
    return a ? a : function(c) {
        return Number.isInteger(c) && Math.abs(c) <= Number.MAX_SAFE_INTEGER
    }
});
x("Math.trunc", function(a) {
    return a ? a : function(c) {
        c = Number(c);
        if (isNaN(c) || Infinity === c || -Infinity === c || 0 === c)
            return c;
        var d = Math.floor(Math.abs(c));
        return 0 > c ? -d : d
    }
});
x("Array.prototype.keys", function(a) {
    return a ? a : function() {
        return ta(this, function(c) {
            return c
        })
    }
});
x("Array.from", function(a) {
    return a ? a : function(c, d, e) {
        d = null != d ? d : function(k) {
            return k
        }
        ;
        var f = []
          , g = "undefined" != typeof Symbol && Symbol.iterator && c[Symbol.iterator];
        if ("function" == typeof g) {
            c = g.call(c);
            for (var h = 0; !(g = c.next()).done; )
                f.push(d.call(e, g.value, h++))
        } else
            for (g = c.length,
            h = 0; h < g; h++)
                f.push(d.call(e, c[h], h));
        return f
    }
});
x("Set", function(a) {
    function c(d) {
        this.g = new Map;
        if (d) {
            d = ha(d);
            for (var e; !(e = d.next()).done; )
                this.add(e.value)
        }
        this.size = this.g.size
    }
    if (function() {
        if (!a || "function" != typeof a || !a.prototype.entries || "function" != typeof Object.seal)
            return !1;
        try {
            var d = Object.seal({
                x: 4
            })
              , e = new a(ha([d]));
            if (!e.has(d) || 1 != e.size || e.add(d) != e || 1 != e.size || e.add({
                x: 4
            }) != e || 2 != e.size)
                return !1;
            var f = e.entries()
              , g = f.next();
            if (g.done || g.value[0] != d || g.value[1] != d)
                return !1;
            g = f.next();
            return g.done || g.value[0] == d || 4 != g.value[0].x || g.value[1] != g.value[0] ? !1 : f.next().done
        } catch (h) {
            return !1
        }
    }())
        return a;
    c.prototype.add = function(d) {
        d = 0 === d ? 0 : d;
        this.g.set(d, d);
        this.size = this.g.size;
        return this
    }
    ;
    c.prototype.delete = function(d) {
        d = this.g.delete(d);
        this.size = this.g.size;
        return d
    }
    ;
    c.prototype.clear = function() {
        this.g.clear();
        this.size = 0
    }
    ;
    c.prototype.has = function(d) {
        return this.g.has(d)
    }
    ;
    c.prototype.entries = function() {
        return this.g.entries()
    }
    ;
    c.prototype.values = function() {
        return this.g.values()
    }
    ;
    c.prototype.keys = c.prototype.values;
    c.prototype[Symbol.iterator] = c.prototype.values;
    c.prototype.forEach = function(d, e) {
        var f = this;
        this.g.forEach(function(g) {
            return d.call(e, g, g, f)
        })
    }
    ;
    return c
});
x("Object.entries", function(a) {
    return a ? a : function(c) {
        var d = [], e;
        for (e in c)
            ua(c, e) && d.push([e, c[e]]);
        return d
    }
});
x("String.prototype.endsWith", function(a) {
    return a ? a : function(c, d) {
        var e = sa(this, c, "endsWith");
        void 0 === d && (d = e.length);
        d = Math.max(0, Math.min(d | 0, e.length));
        for (var f = c.length; 0 < f && 0 < d; )
            if (e[--d] != c[--f])
                return !1;
        return 0 >= f
    }
});
x("Promise.allSettled", function(a) {
    function c(e) {
        return {
            status: "fulfilled",
            value: e
        }
    }
    function d(e) {
        return {
            status: "rejected",
            reason: e
        }
    }
    return a ? a : function(e) {
        var f = this;
        e = Array.from(e, function(g) {
            return f.resolve(g).then(c, d)
        });
        return f.all(e)
    }
});
x("Array.prototype.flatMap", function(a) {
    return a ? a : function(c, d) {
        var e = [];
        Array.prototype.forEach.call(this, function(f, g) {
            f = c.call(d, f, g, this);
            Array.isArray(f) ? e.push.apply(e, f) : e.push(f)
        });
        return e
    }
});
x("String.prototype.matchAll", function(a) {
    return a ? a : function(c) {
        if (c instanceof RegExp && !c.global)
            throw new TypeError("n");
        var d = new RegExp(c,c instanceof RegExp ? void 0 : "g")
          , e = this
          , f = !1
          , g = {
            next: function() {
                if (f)
                    return {
                        value: void 0,
                        done: !0
                    };
                var h = d.exec(e);
                if (!h)
                    return f = !0,
                    {
                        value: void 0,
                        done: !0
                    };
                "" === h[0] && (d.lastIndex += 1);
                return {
                    value: h,
                    done: !1
                }
            }
        };
        g[Symbol.iterator] = function() {
            return g
        }
        ;
        return g
    }
});
x("Promise.prototype.finally", function(a) {
    return a ? a : function(c) {
        return this.then(function(d) {
            return Promise.resolve(c()).then(function() {
                return d
            })
        }, function(d) {
            return Promise.resolve(c()).then(function() {
                throw d;
            })
        })
    }
});
/*

 Copyright The Closure Library Authors.
 SPDX-License-Identifier: Apache-2.0
*/
var va = va || {}
  , z = this || self;
function wa(a) {
    var c = xa("WIZ_global_data.oxN3nb");
    a = c && c[a];
    return null != a ? a : !1
}
var ya = z._F_toggles || [];
function xa(a) {
    a = a.split(".");
    for (var c = z, d = 0; d < a.length; d++)
        if (c = c[a[d]],
        null == c)
            return null;
    return c
}
function za(a) {
    var c = typeof a;
    return "object" != c ? c : a ? Array.isArray(a) ? "array" : c : "null"
}
function Ba(a) {
    var c = za(a);
    return "array" == c || "object" == c && "number" == typeof a.length
}
function Ca(a) {
    var c = typeof a;
    return "object" == c && null != a || "function" == c
}
function Da(a) {
    return Object.prototype.hasOwnProperty.call(a, Ea) && a[Ea] || (a[Ea] = ++Fa)
}
var Ea = "closure_uid_" + (1E9 * Math.random() >>> 0)
  , Fa = 0;
function Ga(a, c, d) {
    return a.call.apply(a.bind, arguments)
}
function Ha(a, c, d) {
    if (!a)
        throw Error();
    if (2 < arguments.length) {
        var e = Array.prototype.slice.call(arguments, 2);
        return function() {
            var f = Array.prototype.slice.call(arguments);
            Array.prototype.unshift.apply(f, e);
            return a.apply(c, f)
        }
    }
    return function() {
        return a.apply(c, arguments)
    }
}
function A(a, c, d) {
    A = Function.prototype.bind && -1 != Function.prototype.bind.toString().indexOf("native code") ? Ga : Ha;
    return A.apply(null, arguments)
}
function Ia(a, c) {
    var d = Array.prototype.slice.call(arguments, 1);
    return function() {
        var e = d.slice();
        e.push.apply(e, arguments);
        return a.apply(this, e)
    }
}
function Ja(a) {
    (0,
    eval)(a)
}
function Ka(a, c) {
    function d() {}
    d.prototype = c.prototype;
    a.ua = c.prototype;
    a.prototype = new d;
    a.prototype.constructor = a;
    a.Zd = function(e, f, g) {
        for (var h = Array(arguments.length - 2), k = 2; k < arguments.length; k++)
            h[k - 2] = arguments[k];
        return c.prototype[f].apply(e, h)
    }
}
function La(a) {
    return a
}
;function Ma(a, c, d, e) {
    e = e ? e(c) : c;
    return Object.prototype.hasOwnProperty.call(a, e) ? a[e] : a[e] = d(c)
}
;function Na(a) {
    return Ma(a.prototype, "$$generatedClassName", function() {
        return "Class$obf_" + {
            valueOf: function() {
                return ++Oa
            }
        }
    })
}
var Oa = 1E3;
function B() {}
B.prototype.na = function(a) {
    return isObject(this, a)
}
;
B.prototype.La = function() {
    return Qa(this)
}
;
B.prototype.toString = function() {
    return C(Ra(Sa(this.constructor))) + "@" + C(Ta(this.La()))
}
;
function Ua() {}
y(Ua, B);
function Va(a, c) {
    a.g = c;
    Wa(a)
}
function Xa(a, c) {
    a.N = c;
    Ya(c, a)
}
function Wa(a) {
    a.N instanceof Error && (Error.captureStackTrace ? Error.captureStackTrace(a.N) : a.N.stack = Error().stack)
}
Ua.prototype.toString = function() {
    var a = Ra(Sa(this.constructor))
      , c = this.g;
    return null == c ? a : C(a) + ": " + C(c)
}
;
function Za(a) {
    if (null != a) {
        var c = a.Ic;
        if (c)
            return c
    }
    a instanceof TypeError ? c = $a() : (c = new ab,
    Wa(c),
    Xa(c, Error(c)));
    c.g = C(a);
    Xa(c, a);
    return c
}
;function bb() {}
y(bb, Ua);
function db() {}
y(db, bb);
function D(a) {
    var c = new db;
    Va(c, a);
    Xa(c, Error(c));
    return c
}
;function eb() {}
y(eb, db);
function fb(a, c) {
    this.g = a;
    this.j = c
}
y(fb, B);
function Ra(a) {
    return 0 != a.j ? C(gb("[", a.j)) + String("L" + C(Na(a.g)) + ";") : Na(a.g)
}
fb.prototype.toString = function() {
    return "class " + C(Ra(this))
}
;
function gb(a, c) {
    for (var d = "", e = 0; e < c; e = e + 1 | 0)
        d = C(d) + C(a);
    return d
}
function Sa(a, c) {
    var d = c || 0;
    return Ma(a.prototype, "$$class/" + d, function() {
        return new fb(a,d)
    })
}
;function isObject(a, c) {
    return Object.is(a, c) || null == a && null == c
}
;var hb;
function ib() {
    ib = n();
    for (var a = jb(), c = 0; 256 > c; c = c + 1 | 0)
        a[c] = kb(c - 128 | 0);
    hb = a
}
;function lb() {}
y(lb, B);
function mb() {}
var nb;
y(mb, B);
function ob() {}
y(ob, mb);
function pb() {}
y(pb, db);
function qb() {
    var a = new pb;
    Wa(a);
    Xa(a, Error(a));
    return a
}
function rb(a) {
    var c = new pb;
    Va(c, a);
    Xa(c, Error(c));
    return c
}
function sb(a, c) {
    var d = new pb;
    d.j = c;
    d.g = a;
    Wa(d);
    Xa(d, Error(d));
    return d
}
;function tb(a, c) {
    if (Error.captureStackTrace)
        Error.captureStackTrace(this, tb);
    else {
        var d = Error().stack;
        d && (this.stack = d)
    }
    a && (this.message = String(a));
    void 0 !== c && (this.cause = c);
    this.g = !0
}
Ka(tb, Error);
tb.prototype.name = "CustomError";
var vb;
function wb(a, c) {
    this.j = a | 0;
    this.g = c | 0
}
function xb(a) {
    return 4294967296 * a.g + (a.j >>> 0)
}
v = wb.prototype;
v.toString = function(a) {
    a = a || 10;
    if (2 > a || 36 < a)
        throw Error("o`" + a);
    var c = this.g >> 21;
    if (0 == c || -1 == c && (0 != this.j || -2097152 != this.g))
        return c = xb(this),
        10 == a ? "" + c : c.toString(a);
    c = 14 - (a >> 2);
    var d = Math.pow(a, c)
      , e = yb(d, d / 4294967296);
    d = zb(this, e);
    e = Math.abs(xb(this.add(Ab(Bb(d, e)))));
    var f = 10 == a ? "" + e : e.toString(a);
    f.length < c && (f = "0000000000000".slice(f.length - c) + f);
    e = xb(d);
    return (10 == a ? e : e.toString(a)) + f
}
;
function Cb(a) {
    return 0 == a.j && 0 == a.g
}
v.La = function() {
    return this.j ^ this.g
}
;
v.na = function(a) {
    return this.j == a.j && this.g == a.g
}
;
function Db(a, c) {
    return a.g == c.g ? a.j == c.j ? 0 : a.j >>> 0 > c.j >>> 0 ? 1 : -1 : a.g > c.g ? 1 : -1
}
function Ab(a) {
    var c = ~a.j + 1 | 0;
    return yb(c, ~a.g + !c | 0)
}
v.add = function(a) {
    var c = this.g >>> 16
      , d = this.g & 65535
      , e = this.j >>> 16
      , f = a.g >>> 16
      , g = a.g & 65535
      , h = a.j >>> 16;
    a = (this.j & 65535) + (a.j & 65535);
    h = (a >>> 16) + (e + h);
    e = h >>> 16;
    e += d + g;
    return yb((h & 65535) << 16 | a & 65535, ((e >>> 16) + (c + f) & 65535) << 16 | e & 65535)
}
;
function Bb(a, c) {
    if (Cb(a))
        return a;
    if (Cb(c))
        return c;
    var d = a.g >>> 16
      , e = a.g & 65535
      , f = a.j >>> 16;
    a = a.j & 65535;
    var g = c.g >>> 16
      , h = c.g & 65535
      , k = c.j >>> 16;
    c = c.j & 65535;
    var l = a * c;
    var m = (l >>> 16) + f * c;
    var p = m >>> 16;
    m = (m & 65535) + a * k;
    p += m >>> 16;
    p += e * c;
    var r = p >>> 16;
    p = (p & 65535) + f * k;
    r += p >>> 16;
    p = (p & 65535) + a * h;
    r = r + (p >>> 16) + (d * c + e * k + f * h + a * g) & 65535;
    return yb((m & 65535) << 16 | l & 65535, r << 16 | p & 65535)
}
function zb(a, c) {
    if (Cb(c))
        throw Error("p");
    if (0 > a.g) {
        if (a.na(Eb)) {
            if (c.na(Fb) || c.na(Gb))
                return Eb;
            if (c.na(Eb))
                return Fb;
            var d = a.g;
            d = yb(a.j >>> 1 | d << 31, d >> 1);
            d = zb(d, c);
            var e = d.j;
            d = yb(e << 1, d.g << 1 | e >>> 31);
            if (d.na(Hb))
                return 0 > c.g ? Fb : Gb;
            a = a.add(Ab(Bb(c, d)));
            return d.add(zb(a, c))
        }
        return 0 > c.g ? zb(Ab(a), Ab(c)) : Ab(zb(Ab(a), c))
    }
    if (Cb(a))
        return Hb;
    if (0 > c.g)
        return c.na(Eb) ? Hb : Ab(zb(a, Ab(c)));
    for (e = Hb; 0 <= Db(a, c); ) {
        d = Math.max(1, Math.floor(xb(a) / xb(c)));
        var f = Math.ceil(Math.log(d) / Math.LN2);
        f = 48 >= f ? 1 : Math.pow(2, f - 48);
        for (var g = Ib(d), h = Bb(g, c); 0 > h.g || 0 < Db(h, a); )
            d -= f,
            g = Ib(d),
            h = Bb(g, c);
        Cb(g) && (g = Fb);
        e = e.add(g);
        a = a.add(Ab(h))
    }
    return e
}
v.and = function(a) {
    return yb(this.j & a.j, this.g & a.g)
}
;
v.or = function(a) {
    return yb(this.j | a.j, this.g | a.g)
}
;
v.xor = function(a) {
    return yb(this.j ^ a.j, this.g ^ a.g)
}
;
function Ib(a) {
    return 0 < a ? 0x7fffffffffffffff <= a ? Jb : new wb(a,a / 4294967296) : 0 > a ? -0x7fffffffffffffff >= a ? Eb : Ab(new wb(-a,-a / 4294967296)) : Hb
}
function yb(a, c) {
    return new wb(a,c)
}
var Hb = yb(0, 0)
  , Fb = yb(1, 0)
  , Gb = yb(-1, -1)
  , Jb = yb(4294967295, 2147483647)
  , Eb = yb(0, 2147483648);
function Kb(a) {
    return Math.max(Math.min(a, 2147483647), -2147483648) | 0
}
;function Lb(a) {
    return 56320 <= a && 57343 >= a
}
;function ab() {}
y(ab, db);
function Mb() {}
y(Mb, ab);
function $a() {
    var a = new Mb;
    Wa(a);
    Xa(a, new TypeError(a));
    return a
}
;function Nb() {}
y(Nb, B);
Nb.prototype.toString = q("g");
function Ob() {}
y(Ob, db);
function Pb(a) {
    var c = new Ob;
    Va(c, a);
    Xa(c, Error(c));
    return c
}
;function Qb() {
    this.g = 0
}
y(Qb, mb);
function Ta(a) {
    return (a >>> 0).toString(16)
}
function Rb(a) {
    -129 < a && 128 > a ? (ib(),
    a = hb[a + 128 | 0]) : a = kb(a);
    return a
}
function kb(a) {
    var c = new Qb;
    c.g = a;
    return c
}
Qb.prototype.na = function(a) {
    return Sb(a) && a.g == this.g
}
;
Qb.prototype.La = q("g");
Qb.prototype.toString = function() {
    return "" + this.g
}
;
function Sb(a) {
    return a instanceof Qb
}
;function Tb() {}
y(Tb, Nb);
function Ub(a, c) {
    a.g = C(a.g) + C(c);
    return a
}
;function Vb() {}
y(Vb, B);
Vb.prototype.toString = function() {
    return this.g ? 0 == this.j.length ? this.g.toString() : C(this.g.toString()) + C(this.j) : this.A
}
;
function Wb(a, c) {
    if (isObject(a, c))
        return !0;
    if (!a || !c || a.length != c.length)
        return !1;
    for (var d = 0; d < a.length; d = d + 1 | 0) {
        var e = a[d]
          , f = c[d];
        if (!(isObject(e, f) || null != e && Xb(e, f)))
            return !1
    }
    return !0
}
function Yb(a) {
    if (!a)
        return 0;
    for (var c = 1, d = 0; d < a.length; d++) {
        c = Math.imul(31, c);
        var e = a[d];
        e = null != e ? Zb(e) : 0;
        c = c + e | 0
    }
    return c
}
;function $b() {}
y($b, Ob);
function ac(a) {
    switch (typeof a) {
    case "string":
        for (var c = 0, d = 0; d < a.length; d = d + 1 | 0)
            c = (c << 5) - c + a.charCodeAt(d) | 0;
        return c;
    case "number":
        return Kb(a);
    case "boolean":
        return a ? 1231 : 1237;
    default:
        return null == a ? 0 : Qa(a)
    }
}
var bc = 0;
function Qa(a) {
    return a.dc || (Object.defineProperties(a, {
        dc: {
            value: bc = bc + 1 | 0,
            enumerable: !1
        }
    }),
    a.dc)
}
;function Xb(a, c) {
    return a.na ? a.na(c) : Object.is(a, c)
}
function Zb(a) {
    return a.La ? a.La() : ac(a)
}
function cc(a) {
    switch (typeof a) {
    case "number":
        return Sa(ob);
    case "boolean":
        return Sa(lb);
    case "string":
        return Sa(dc);
    case "function":
        return Sa(ec)
    }
    if (a instanceof B)
        a = Sa(a.constructor);
    else if (Array.isArray(a))
        a = (a = a.xb) ? Sa(a.Ib, a.Vb) : Sa(B, 1);
    else if (null != a)
        a = Sa(fc);
    else
        throw new TypeError("r");
    return a
}
;function ec() {}
;function fc() {}
y(fc, B);
function jb() {
    var a = [256];
    return gc(a, {
        Ib: Qb,
        zc: Sb,
        Vb: a.length
    })
}
function gc(a, c) {
    var d = a[0];
    if (null == d)
        return null;
    var e = new globalThis.Array(d);
    c && (e.xb = c);
    if (1 < a.length) {
        a = a.slice(1);
        c = c && {
            Ib: c.Ib,
            zc: c.zc,
            Vb: c.Vb - 1
        };
        for (var f = 0; f < d; f++)
            e[f] = gc(a, c)
    } else if (c && (a = c.Ib.ud,
    void 0 !== a))
        for (c = 0; c < d; c++)
            e[c] = a;
    return e
}
;function Ya(a, c) {
    if (a instanceof Object)
        try {
            a.Ic = c,
            Object.defineProperties(a, {
                cause: {
                    get: function() {
                        return c.j && c.j.N
                    }
                }
            })
        } catch (d) {}
}
;function dc() {}
y(dc, B);
function C(a) {
    return null == a ? "null" : a.toString()
}
function hc(a, c) {
    var d = a.length, e, f = (e = c,
    c = c + 1 | 0,
    e);
    e = "string" === typeof a ? a.charCodeAt(f) : a.g.charCodeAt(f);
    var g, h;
    55296 <= e && 56319 >= e && c < d && Lb(g = "string" === typeof a ? a.charCodeAt(c) : a.g.charCodeAt(c)) ? h = 65536 + ((e & 1023) << 10) + (g & 1023) | 0 : h = e;
    return h
}
function ic(a, c) {
    return isObject(a, c)
}
function jc(a) {
    var c = String.fromCodePoint(35);
    return a.indexOf(c)
}
;function kc(a) {
    z.setTimeout(function() {
        throw a;
    }, 0)
}
;function lc(a, c) {
    return 0 == a.lastIndexOf(c, 0)
}
function mc(a) {
    return /^[\s\xa0]*$/.test(a)
}
var nc = String.prototype.trim ? function(a) {
    return a.trim()
}
: function(a) {
    return /^[\s\xa0]*([\s\S]*?)[\s\xa0]*$/.exec(a)[1]
}
  , oc = /&/g
  , pc = /</g
  , qc = />/g
  , rc = /"/g
  , tc = /'/g
  , uc = /\x00/g
  , vc = /[\x00&<>"']/;
function wc() {
    for (var a = 0, c = nc(String(xc)).split("."), d = nc("58.0.3029.52").split("."), e = Math.max(c.length, d.length), f = 0; 0 == a && f < e; f++) {
        var g = c[f] || ""
          , h = d[f] || "";
        do {
            g = /(\d*)(\D*)(.*)/.exec(g) || ["", "", "", ""];
            h = /(\d*)(\D*)(.*)/.exec(h) || ["", "", "", ""];
            if (0 == g[0].length && 0 == h[0].length)
                break;
            a = yc(0 == g[1].length ? 0 : parseInt(g[1], 10), 0 == h[1].length ? 0 : parseInt(h[1], 10)) || yc(0 == g[2].length, 0 == h[2].length) || yc(g[2], h[2]);
            g = g[3];
            h = h[3]
        } while (0 == a)
    }
    return a
}
function yc(a, c) {
    return a < c ? -1 : a > c ? 1 : 0
}
;var zc = !!(ya[0] & 128)
  , Ac = !!(ya[0] & 256)
  , Bc = !!(ya[0] & 2);
var Cc = zc ? Ac : wa(610401301)
  , Dc = zc ? Bc : wa(188588736);
function Ec() {
    var a = z.navigator;
    return a && (a = a.userAgent) ? a : ""
}
var Fc, Gc = z.navigator;
Fc = Gc ? Gc.userAgentData || null : null;
function Hc(a) {
    return Cc ? Fc ? Fc.brands.some(function(c) {
        return (c = c.brand) && -1 != c.indexOf(a)
    }) : !1 : !1
}
function E(a) {
    return -1 != Ec().indexOf(a)
}
;function Ic() {
    return Cc ? !!Fc && 0 < Fc.brands.length : !1
}
function Jc() {
    return E("Firefox") || E("FxiOS")
}
function Kc() {
    return Ic() ? Hc("Chromium") : (E("Chrome") || E("CriOS")) && !(Ic() ? 0 : E("Edge")) || E("Silk")
}
function Lc(a) {
    var c = {};
    a.forEach(function(d) {
        c[d[0]] = d[1]
    });
    return function(d) {
        return c[d.find(function(e) {
            return e in c
        })] || ""
    }
}
function Mc() {
    for (var a = Ec(), c = RegExp("([A-Z][\\w ]+)/([^\\s]+)\\s*(?:\\((.*?)\\))?", "g"), d = [], e; e = c.exec(a); )
        d.push([e[1], e[2], e[3] || void 0]);
    a = Lc(d);
    return Kc() ? a(["Chrome", "CriOS", "HeadlessChrome"]) : ""
}
function Nc() {
    if (Ic()) {
        var a = Fc.brands.find(function(c) {
            return "Chromium" === c.brand
        });
        if (!a || !a.version)
            return NaN;
        a = a.version.split(".")
    } else {
        a = Mc();
        if ("" === a)
            return NaN;
        a = a.split(".")
    }
    return 0 === a.length ? NaN : Number(a[0])
}
;function Oc() {
    return E("iPhone") && !E("iPod") && !E("iPad")
}
function Pc() {
    return Oc() || E("iPad") || E("iPod")
}
;function Qc(a, c) {
    return Array.prototype.indexOf.call(a, c, void 0)
}
function Rc(a, c) {
    Array.prototype.forEach.call(a, c, void 0)
}
function Sc(a, c) {
    return Array.prototype.some.call(a, c, void 0)
}
function Tc(a, c) {
    return 0 <= Qc(a, c)
}
function Uc(a, c) {
    c = Qc(a, c);
    var d;
    (d = 0 <= c) && Array.prototype.splice.call(a, c, 1);
    return d
}
function Vc(a) {
    var c = a.length;
    if (0 < c) {
        for (var d = Array(c), e = 0; e < c; e++)
            d[e] = a[e];
        return d
    }
    return []
}
function Wc(a, c) {
    for (var d = 1; d < arguments.length; d++) {
        var e = arguments[d];
        if (Ba(e)) {
            var f = a.length || 0
              , g = e.length || 0;
            a.length = f + g;
            for (var h = 0; h < g; h++)
                a[f + h] = e[h]
        } else
            a.push(e)
    }
}
function Xc(a, c, d) {
    function e(m) {
        return Ca(m) ? "o" + Da(m) : (typeof m).charAt(0) + m
    }
    c = c || a;
    d = d || e;
    for (var f = 0, g = 0, h = {}; g < a.length; ) {
        var k = a[g++]
          , l = d(k);
        Object.prototype.hasOwnProperty.call(h, l) || (h[l] = !0,
        c[f++] = k)
    }
    c.length = f
}
function Yc(a, c) {
    if (!Ba(a) || !Ba(c) || a.length != c.length)
        return !1;
    for (var d = a.length, e = Zc, f = 0; f < d; f++)
        if (!e(a[f], c[f]))
            return !1;
    return !0
}
function Zc(a, c) {
    return a === c
}
;var $c = Jc()
  , ad = Oc() || E("iPod")
  , cd = E("iPad")
  , dd = E("Android") && !(Kc() || Jc() || (Ic() ? 0 : E("Opera")) || E("Silk"))
  , ed = Kc()
  , fd = E("Safari") && !(Kc() || (Ic() ? 0 : E("Coast")) || (Ic() ? 0 : E("Opera")) || (Ic() ? 0 : E("Edge")) || (Ic() ? Hc("Microsoft Edge") : E("Edg/")) || (Ic() ? Hc("Opera") : E("OPR")) || Jc() || E("Silk") || E("Android")) && !Pc();
var gd = {}
  , hd = null;
function id(a) {
    var c = [];
    jd(a, function(d) {
        c.push(d)
    });
    return c
}
function kd(a) {
    var c = a.length
      , d = 3 * c / 4;
    d % 3 ? d = Math.floor(d) : -1 != "=.".indexOf(a[c - 1]) && (d = -1 != "=.".indexOf(a[c - 2]) ? d - 2 : d - 1);
    var e = new Uint8Array(d)
      , f = 0;
    jd(a, function(g) {
        e[f++] = g
    });
    return f !== d ? e.subarray(0, f) : e
}
function jd(a, c) {
    function d(l) {
        for (; e < a.length; ) {
            var m = a.charAt(e++)
              , p = hd[m];
            if (null != p)
                return p;
            if (!mc(m))
                throw Error("y`" + m);
        }
        return l
    }
    ld();
    for (var e = 0; ; ) {
        var f = d(-1)
          , g = d(0)
          , h = d(64)
          , k = d(64);
        if (64 === k && -1 === f)
            break;
        c(f << 2 | g >> 4);
        64 != h && (c(g << 4 & 240 | h >> 2),
        64 != k && c(h << 6 & 192 | k))
    }
}
function ld() {
    if (!hd) {
        hd = {};
        for (var a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".split(""), c = ["+/=", "+/", "-_=", "-_.", "-_"], d = 0; 5 > d; d++) {
            var e = a.concat(c[d].split(""));
            gd[d] = e;
            for (var f = 0; f < e.length; f++) {
                var g = e[f];
                void 0 === hd[g] && (hd[g] = f)
            }
        }
    }
}
;var md = "undefined" !== typeof Uint8Array
  , nd = "function" === typeof btoa;
function od(a) {
    if (!nd) {
        var c;
        void 0 === c && (c = 0);
        ld();
        c = gd[c];
        for (var d = Array(Math.floor(a.length / 3)), e = c[64] || "", f = 0, g = 0; f < a.length - 2; f += 3) {
            var h = a[f]
              , k = a[f + 1]
              , l = a[f + 2]
              , m = c[h >> 2];
            h = c[(h & 3) << 4 | k >> 4];
            k = c[(k & 15) << 2 | l >> 6];
            l = c[l & 63];
            d[g++] = m + h + k + l
        }
        m = 0;
        l = e;
        switch (a.length - f) {
        case 2:
            m = a[f + 1],
            l = c[(m & 15) << 2] || e;
        case 1:
            a = a[f],
            d[g] = c[a >> 2] + c[(a & 3) << 4 | m >> 4] + l + e
        }
        return d.join("")
    }
    c = "";
    d = 0;
    for (e = a.length - 10240; d < e; )
        c += String.fromCharCode.apply(null, a.subarray(d, d += 10240));
    c += String.fromCharCode.apply(null, d ? a.subarray(d) : a);
    return btoa(c)
}
var pd = /[-_.]/g
  , qd = {
    "-": "+",
    _: "/",
    ".": "="
};
function rd(a) {
    return qd[a] || ""
}
function sd(a) {
    if (!nd)
        return kd(a);
    pd.test(a) && (a = a.replace(pd, rd));
    a = atob(a);
    for (var c = new Uint8Array(a.length), d = 0; d < a.length; d++)
        c[d] = a.charCodeAt(d);
    return c
}
function td(a) {
    return md && null != a && a instanceof Uint8Array
}
var ud, vd = {};
var wd;
function xd(a, c) {
    if (c !== vd)
        throw Error("z");
    this.g = a;
    if (null != a && 0 === a.length)
        throw Error("A");
}
function yd(a) {
    var c = a.g;
    return null == c ? "" : "string" === typeof c ? c : a.g = od(c)
}
function zd(a, c) {
    if (!a.g || !c.g || a.g === c.g)
        return a.g === c.g;
    if ("string" === typeof a.g && "string" === typeof c.g) {
        var d = a.g
          , e = c.g;
        c.g.length > a.g.length && (e = a.g,
        d = c.g);
        if (0 !== d.lastIndexOf(e, 0))
            return !1;
        for (c = e.length; c < d.length; c++)
            if ("=" !== d[c])
                return !1;
        return !0
    }
    d = Ad(a);
    c = Ad(c);
    a: if (a = d.length,
    a !== c.length)
        c = !1;
    else {
        for (e = 0; e < a; e++)
            if (d[e] !== c[e]) {
                c = !1;
                break a
            }
        c = !0
    }
    return c
}
function Ad(a) {
    if (vd !== vd)
        throw Error("z");
    var c = a.g;
    c = null == c || td(c) ? c : "string" === typeof c ? sd(c) : null;
    return null == c ? c : a.g = c
}
;function Bd(a) {
    return "=" === a || "." === a
}
;xd.prototype.na = function(a) {
    return zd(this, a)
}
;
xd.prototype.La = function() {
    for (var a = yd(this), c = 1, d = a.length; Bd(a[d - 1]); )
        d--;
    for (var e = d - 4, f = 0; f < e; )
        c = a.charCodeAt(f) + 31 * c | 0,
        c = a.charCodeAt(f + 1) + 31 * c | 0,
        c = a.charCodeAt(f + 2) + 31 * c | 0,
        c = a.charCodeAt(f + 3) + 31 * c | 0,
        f += 4;
    for (; f < d; )
        c = a.charCodeAt(f++) + 31 * c | 0;
    return c
}
;
function Cd() {
    return "function" === typeof BigInt
}
;function Dd(a) {
    return Array.prototype.slice.call(a)
}
;function Ed(a) {
    return "function" === typeof Symbol && "symbol" === typeof Symbol() ? Symbol() : a
}
var Fd = Ed()
  , Gd = Ed("0di");
Math.max.apply(Math, ja(Object.values({
    Kd: 1,
    Hd: 2,
    Fd: 4,
    Sd: 8,
    Rd: 16,
    Pd: 32,
    xd: 64,
    Xd: 128,
    Ed: 256,
    Dd: 512,
    Id: 1024,
    Bd: 2048,
    Wd: 4096,
    Cd: 8192
})));
var Hd = Fd ? function(a, c) {
    a[Fd] |= c
}
: function(a, c) {
    void 0 !== a.za ? a.za |= c : Object.defineProperties(a, {
        za: {
            value: c,
            configurable: !0,
            writable: !0,
            enumerable: !1
        }
    })
}
  , Id = Fd ? function(a, c) {
    a[Fd] &= ~c
}
: function(a, c) {
    void 0 !== a.za && (a.za &= ~c)
}
;
function Jd(a, c, d) {
    return d ? a | c : a & ~c
}
var Kd = Fd ? function(a) {
    return a[Fd] | 0
}
: function(a) {
    return a.za | 0
}
  , Ld = Fd ? function(a) {
    return a[Fd]
}
: function(a) {
    return a.za
}
  , Md = Fd ? function(a, c) {
    a[Fd] = c;
    return a
}
: function(a, c) {
    void 0 !== a.za ? a.za = c : Object.defineProperties(a, {
        za: {
            value: c,
            configurable: !0,
            writable: !0,
            enumerable: !1
        }
    });
    return a
}
;
function Nd(a, c) {
    Md(c, (a | 0) & -14591)
}
function Od(a, c) {
    Md(c, (a | 34) & -14557)
}
function Pd(a) {
    a = a >> 14 & 1023;
    return 0 === a ? 536870912 : a
}
;var Qd = {}
  , Rd = {};
function Sd(a) {
    return !(!a || "object" !== typeof a || a.g !== Rd)
}
function Td(a) {
    return null !== a && "object" === typeof a && !Array.isArray(a) && a.constructor === Object
}
var Ud;
function Vd(a, c, d) {
    if (!Array.isArray(a) || a.length)
        return !1;
    var e = Kd(a);
    if (e & 1)
        return !0;
    if (!(c && (Array.isArray(c) ? c.includes(d) : c.has(d))))
        return !1;
    Md(a, e | 1);
    return !0
}
var Wd, Xd = [];
Md(Xd, 55);
Wd = Object.freeze(Xd);
function Yd(a) {
    if (a & 2)
        throw Error();
}
var Zd;
function $d(a, c) {
    (c = Zd ? c[Zd] : void 0) && (a[Zd] = Dd(c))
}
var ae;
Object.freeze(new (n()));
Object.freeze(new (n()));
var be = "function" === typeof Uint8Array.prototype.slice
  , ce = 0
  , de = 0;
function ee(a) {
    var c = 0 > a;
    a = Math.abs(a);
    var d = a >>> 0;
    a = Math.floor((a - d) / 4294967296);
    c && (d = ha(fe(d, a)),
    c = d.next().value,
    a = d.next().value,
    d = c);
    ce = d >>> 0;
    de = a >>> 0
}
function ge(a, c) {
    c >>>= 0;
    a >>>= 0;
    if (2097151 >= c)
        var d = "" + (4294967296 * c + a);
    else
        Cd() ? d = "" + (BigInt(c) << BigInt(32) | BigInt(a)) : (d = (a >>> 24 | c << 8) & 16777215,
        c = c >> 16 & 65535,
        a = (a & 16777215) + 6777216 * d + 6710656 * c,
        d += 8147497 * c,
        c *= 2,
        1E7 <= a && (d += Math.floor(a / 1E7),
        a %= 1E7),
        1E7 <= d && (c += Math.floor(d / 1E7),
        d %= 1E7),
        d = c + he(d) + he(a));
    return d
}
function he(a) {
    a = String(a);
    return "0000000".slice(a.length) + a
}
function ie() {
    var a = ce
      , c = de;
    c & 2147483648 ? Cd() ? a = "" + (BigInt(c | 0) << BigInt(32) | BigInt(a >>> 0)) : (c = ha(fe(a, c)),
    a = c.next().value,
    c = c.next().value,
    a = "-" + ge(a, c)) : a = ge(a, c);
    return a
}
function fe(a, c) {
    c = ~c;
    a ? a = ~a + 1 : c += 1;
    return [a, c]
}
;function je(a, c, d) {
    a.__closure__error__context__984382 || (a.__closure__error__context__984382 = {});
    a.__closure__error__context__984382[c] = d
}
function ke(a) {
    return a.__closure__error__context__984382 || {}
}
;function le(a) {
    a = Error(a);
    je(a, "severity", "warning");
    return a
}
;function me(a) {
    return a.displayName || a.name || "unknown type name"
}
var ne = /^-?([1-9][0-9]*|0)(\.[0-9]+)?$/;
function oe(a) {
    var c = typeof a;
    return "number" === c ? Number.isFinite(a) : "string" !== c ? !1 : ne.test(a)
}
function pe(a) {
    if (!Number.isFinite(a))
        throw le("enum");
    return a | 0
}
function qe(a) {
    return null == a ? a : Number.isFinite(a) ? a | 0 : void 0
}
function re(a) {
    if ("number" !== typeof a)
        throw le("int32");
    if (!Number.isFinite(a))
        throw le("int32");
    return a | 0
}
function se(a) {
    if (null == a)
        return a;
    if ("string" === typeof a) {
        if (!a)
            return;
        a = +a
    }
    if ("number" === typeof a)
        return Number.isFinite(a) ? a | 0 : void 0
}
function te(a) {
    if (null != a) {
        var c = !!c;
        if (!oe(a))
            throw le("int64");
        a = "string" === typeof a ? ue(a) : c ? ve(a) : we(a)
    }
    return a
}
function xe(a) {
    return "-" === a[0] ? 20 > a.length ? !0 : 20 === a.length && -922337 < Number(a.substring(0, 7)) : 19 > a.length ? !0 : 19 === a.length && 922337 > Number(a.substring(0, 6))
}
function we(a) {
    oe(a);
    a = Math.trunc(a);
    if (!Number.isSafeInteger(a)) {
        ee(a);
        var c = ce
          , d = de;
        if (a = d & 2147483648)
            c = ~c + 1 >>> 0,
            d = ~d >>> 0,
            0 == c && (d = d + 1 >>> 0);
        c = 4294967296 * d + (c >>> 0);
        a = a ? -c : c
    }
    return a
}
function ve(a) {
    oe(a);
    a = Math.trunc(a);
    if (Number.isSafeInteger(a))
        a = String(a);
    else {
        var c = String(a);
        xe(c) ? a = c : (ee(a),
        a = ie())
    }
    return a
}
function ue(a) {
    oe(a);
    var c = Math.trunc(Number(a));
    if (Number.isSafeInteger(c))
        return String(c);
    c = a.indexOf(".");
    -1 !== c && (a = a.substring(0, c));
    if (!xe(a)) {
        if (16 > a.length)
            ee(Number(a));
        else if (Cd())
            a = BigInt(a),
            ce = Number(a & BigInt(4294967295)) >>> 0,
            de = Number(a >> BigInt(32) & BigInt(4294967295));
        else {
            c = +("-" === a[0]);
            de = ce = 0;
            for (var d = a.length, e = c, f = (d - c) % 6 + c; f <= d; e = f,
            f += 6)
                e = Number(a.slice(e, f)),
                de *= 1E6,
                ce = 1E6 * ce + e,
                4294967296 <= ce && (de += Math.trunc(ce / 4294967296),
                de >>>= 0,
                ce >>>= 0);
            c && (c = ha(fe(ce, de)),
            a = c.next().value,
            c = c.next().value,
            ce = a,
            de = c)
        }
        a = ie()
    }
    return a
}
function ye(a, c) {
    if (!(a instanceof c))
        throw Error("C`" + me(c) + "`" + (a && me(a.constructor)));
}
function ze(a, c, d) {
    if (null != a && "object" === typeof a && a.tb === Qd)
        return a;
    if (Array.isArray(a)) {
        var e = Kd(a)
          , f = e;
        0 === f && (f |= d & 32);
        f |= d & 2;
        f !== e && Md(a, f);
        return new c(a)
    }
}
;var Ae;
function Be(a, c) {
    Ae = c;
    a = new a(c);
    Ae = void 0;
    return a
}
var Ce, De;
function Ee(a) {
    switch (typeof a) {
    case "boolean":
        return Ce || (Ce = [0, void 0, !0]);
    case "number":
        return 0 < a ? void 0 : 0 === a ? De || (De = [0, void 0]) : [-a, void 0];
    case "string":
        return [0, a];
    case "object":
        return a
    }
}
function G(a, c, d) {
    null == a && (a = Ae);
    Ae = void 0;
    if (null == a) {
        var e = 96;
        d ? (a = [d],
        e |= 512) : a = [];
        c && (e = e & -16760833 | (c & 1023) << 14)
    } else {
        if (!Array.isArray(a))
            throw Error();
        e = Kd(a);
        if (e & 64)
            return a;
        e |= 64;
        if (d && (e |= 512,
        d !== a[0]))
            throw Error();
        a: {
            d = a;
            var f = d.length;
            if (f) {
                var g = f - 1;
                if (Td(d[g])) {
                    e |= 256;
                    c = g - (+!!(e & 512) - 1);
                    if (1024 <= c)
                        throw Error();
                    e = e & -16760833 | (c & 1023) << 14;
                    break a
                }
            }
            if (c) {
                c = Math.max(c, f - (+!!(e & 512) - 1));
                if (1024 < c)
                    throw Error();
                e = e & -16760833 | (c & 1023) << 14
            }
        }
    }
    Md(a, e);
    return a
}
;function Fe(a, c) {
    return Ge(c)
}
function Ge(a) {
    switch (typeof a) {
    case "number":
        return isFinite(a) ? a : String(a);
    case "boolean":
        return a ? 1 : 0;
    case "object":
        if (a)
            if (Array.isArray(a)) {
                if (Vd(a, void 0, 0))
                    return
            } else {
                if (td(a))
                    return od(a);
                if (a instanceof xd)
                    return yd(a)
            }
    }
    return a
}
;function He(a, c, d) {
    var e = Dd(a)
      , f = e.length
      , g = c & 256 ? e[f - 1] : void 0;
    f += g ? -1 : 0;
    for (c = c & 512 ? 1 : 0; c < f; c++)
        e[c] = d(e[c]);
    if (g) {
        c = e[c] = {};
        for (var h in g)
            c[h] = d(g[h])
    }
    $d(e, a);
    return e
}
function Ie(a, c, d, e, f) {
    if (null != a) {
        if (Array.isArray(a))
            a = Vd(a, void 0, 0) ? void 0 : f && Kd(a) & 2 ? a : Je(a, c, d, void 0 !== e, f);
        else if (Td(a)) {
            var g = {}, h;
            for (h in a)
                g[h] = Ie(a[h], c, d, e, f);
            a = g
        } else
            a = c(a, e);
        return a
    }
}
function Je(a, c, d, e, f) {
    var g = e || d ? Kd(a) : 0;
    e = e ? !!(g & 32) : void 0;
    for (var h = Dd(a), k = 0; k < h.length; k++)
        h[k] = Ie(h[k], c, d, e, f);
    d && ($d(h, a),
    d(g, h));
    return h
}
function Ke(a) {
    a.tb === Qd ? a = Le(a, Me(a.G), !0) : a instanceof xd ? (a = a.g || "",
    a = "string" === typeof a ? a : new Uint8Array(a)) : a = td(a) ? new Uint8Array(a) : a;
    return a
}
function Ne(a) {
    return a.tb === Qd ? a.toJSON() : Ge(a)
}
function Me(a) {
    return Je(a, Ke, void 0, void 0, !1)
}
;function Oe(a, c, d) {
    d = void 0 === d ? Od : d;
    if (null != a) {
        if (md && a instanceof Uint8Array)
            return c ? a : new Uint8Array(a);
        if (Array.isArray(a)) {
            var e = Kd(a);
            if (e & 2)
                return a;
            c && (c = 0 === e || !!(e & 32) && !(e & 64 || !(e & 16)));
            return c ? Md(a, (e | 34) & -12293) : Je(a, Oe, e & 4 ? Od : d, !0, !0)
        }
        a.tb === Qd && (d = a.G,
        e = Ld(d),
        a = e & 2 ? a : Be(a.constructor, Pe(d, e, !0)));
        return a
    }
}
function Pe(a, c, d) {
    var e = d || c & 2 ? Od : Nd
      , f = !!(c & 32);
    a = He(a, c, function(g) {
        return Oe(g, f, e)
    });
    Hd(a, 32 | (d ? 2 : 0));
    return a
}
function Qe(a) {
    var c = a.G
      , d = Ld(c);
    return d & 2 ? Be(a.constructor, Pe(c, d, !1)) : a
}
;function Re(a, c) {
    a = a.G;
    return Se(a, Ld(a), c)
}
function Se(a, c, d, e) {
    if (-1 === d)
        return null;
    if (d >= Pd(c)) {
        if (c & 256)
            return a[a.length - 1][d]
    } else {
        var f = a.length;
        if (e && c & 256 && (e = a[f - 1][d],
        null != e))
            return e;
        c = d + (+!!(c & 512) - 1);
        if (c < f)
            return a[c]
    }
}
function Te(a, c, d, e) {
    var f = a.G
      , g = Ld(f);
    Yd(g);
    Ue(f, g, c, d, e);
    return a
}
function Ue(a, c, d, e, f) {
    var g = Pd(c);
    if (d >= g || f) {
        var h = c;
        if (c & 256)
            f = a[a.length - 1];
        else {
            if (null == e)
                return h;
            f = a[g + (+!!(c & 512) - 1)] = {};
            h |= 256
        }
        f[d] = e;
        d < g && (a[d + (+!!(c & 512) - 1)] = void 0);
        h !== c && Md(a, h);
        return h
    }
    a[d + (+!!(c & 512) - 1)] = e;
    c & 256 && (a = a[a.length - 1],
    d in a && delete a[d]);
    return c
}
function Ve(a, c, d) {
    return void 0 !== We(a, c, d, !1)
}
function Xe(a, c, d, e, f) {
    var g = c & 2
      , h = Se(a, c, d, f);
    Array.isArray(h) || (h = Wd);
    var k = !(e & 2);
    e = !(e & 1);
    var l = !!(c & 32)
      , m = Kd(h);
    0 !== m || !l || g || k ? m & 1 || (m |= 1,
    Md(h, m)) : (m |= 33,
    Md(h, m));
    g ? (a = !1,
    m & 2 || (Hd(h, 34),
    a = !!(4 & m)),
    (e || a) && Object.freeze(h)) : (g = !!(2 & m) || !!(2048 & m),
    e && g ? (h = Dd(h),
    e = 1,
    l && !k && (e |= 32),
    Md(h, e),
    Ue(a, c, d, h, f)) : k && m & 32 && !g && Id(h, 32));
    return h
}
function Ye(a, c) {
    a = Re(a, c);
    return null == a || "boolean" === typeof a ? a : "number" === typeof a ? !!a : void 0
}
function Ze(a, c, d) {
    a = Se(a, c, d);
    return Array.isArray(a) ? a : Wd
}
function $e(a, c, d) {
    0 === a && (a = af(a, c, d));
    return a = Jd(a, 1, !0)
}
function bf(a) {
    return !!(2 & a) && !!(4 & a) || !!(2048 & a)
}
function cf(a, c, d, e) {
    var f = a.G
      , g = Ld(f);
    Yd(g);
    if (null == d)
        return Ue(f, g, c),
        a;
    if (!Array.isArray(d))
        throw le();
    var h = Kd(d)
      , k = h
      , l = !!(2 & h) || Object.isFrozen(d)
      , m = !l && !1;
    if (!(4 & h))
        for (h = 21,
        l && (d = Dd(d),
        k = 0,
        h = af(h, g, !0)),
        l = 0; l < d.length; l++)
            d[l] = e(d[l]);
    m && (d = Dd(d),
    k = 0,
    h = af(h, g, !0));
    h !== k && Md(d, h);
    Ue(f, g, c, d);
    return a
}
function df(a, c, d, e) {
    var f = Ld(a);
    Yd(f);
    var g = Se(a, f, d, e), h;
    if (null != g && g.tb === Qd)
        return c = Qe(g),
        c !== g && Ue(a, f, d, c, e),
        c.G;
    if (Array.isArray(g)) {
        var k = Kd(g);
        k & 2 ? h = Pe(g, k, !1) : h = g;
        h = G(h, c[0], c[1])
    } else
        h = G(void 0, c[0], c[1]);
    h !== g && Ue(a, f, d, h, e);
    return h
}
function We(a, c, d, e) {
    a = a.G;
    var f = Ld(a)
      , g = Se(a, f, d, e);
    c = ze(g, c, f);
    c !== g && null != c && Ue(a, f, d, c, e);
    return c
}
function H(a, c, d, e) {
    e = void 0 === e ? !1 : e;
    c = We(a, c, d, e);
    if (null == c)
        return c;
    a = a.G;
    var f = Ld(a);
    if (!(f & 2)) {
        var g = Qe(c);
        g !== c && (c = g,
        Ue(a, f, d, c, e))
    }
    return c
}
function ef(a, c, d) {
    a = a.G;
    var e = Ld(a)
      , f = e
      , g = !(2 & e)
      , h = !!(2 & f)
      , k = h ? 1 : 2;
    e = 1 === k;
    k = 2 === k;
    g && (g = !h);
    h = Ze(a, f, d);
    var l = Kd(h)
      , m = !!(4 & l);
    if (!m) {
        l = $e(l, f, !1);
        var p = h
          , r = f
          , u = !!(2 & l);
        u && (r = Jd(r, 2, !0));
        for (var w = !u, F = !0, L = 0, ra = 0; L < p.length; L++) {
            var cb = ze(p[L], c, r);
            if (cb instanceof c) {
                if (!u) {
                    var Aa = !!(Kd(cb.G) & 2);
                    w && (w = !Aa);
                    F && (F = Aa)
                }
                p[ra++] = cb
            }
        }
        ra < L && (p.length = ra);
        l = Jd(l, 4, !0);
        l = Jd(l, 16, F);
        l = Jd(l, 8, w);
        Md(p, l);
        u && Object.freeze(p)
    }
    c = !!(8 & l) || e && !h.length;
    if (g && !c) {
        bf(l) && (h = Dd(h),
        l = af(l, f, !1),
        f = Ue(a, f, d, h));
        c = h;
        g = l;
        for (p = 0; p < c.length; p++)
            l = c[p],
            r = Qe(l),
            l !== r && (c[p] = r);
        g = Jd(g, 8, !0);
        g = Jd(g, 16, !c.length);
        Md(c, g);
        l = g
    }
    bf(l) || (c = l,
    e ? l = Jd(l, !h.length || 16 & l && (!m || 32 & l) ? 2 : 2048, !0) : l = Jd(l, 32, !1),
    l !== c && Md(h, l),
    e && Object.freeze(h));
    k && bf(l) && (h = Dd(h),
    l = af(l, f, !1),
    Md(h, l),
    Ue(a, f, d, h));
    return h
}
function I(a, c, d, e, f) {
    null != e ? ye(e, c) : e = void 0;
    return Te(a, d, e, f)
}
function ff(a, c, d, e) {
    var f = a.G
      , g = Ld(f);
    Yd(g);
    if (null == e)
        return Ue(f, g, d),
        a;
    if (!Array.isArray(e))
        throw le();
    for (var h = Kd(e), k = h, l = !!(2 & h) || !!(2048 & h), m = l || Object.isFrozen(e), p = !m && !1, r = !0, u = !0, w = 0; w < e.length; w++) {
        var F = e[w];
        ye(F, c);
        l || (F = !!(Kd(F.G) & 2),
        r && (r = !F),
        u && (u = F))
    }
    l || (h = Jd(h, 5, !0),
    h = Jd(h, 8, r),
    h = Jd(h, 16, u));
    if (p || m && h !== k)
        e = Dd(e),
        k = 0,
        h = af(h, g, !0);
    h !== k && Md(e, h);
    Ue(f, g, d, e);
    return a
}
function af(a, c, d) {
    a = Jd(a, 2, !!(2 & c));
    a = Jd(a, 32, !!(32 & c) && d);
    return a = Jd(a, 2048, !1)
}
function gf(a, c) {
    a = Re(a, c);
    var d;
    null == a ? d = a : oe(a) ? "number" === typeof a ? d = we(a) : d = ue(a) : d = void 0;
    return d
}
function hf(a) {
    a = Re(a, 1);
    var c = void 0 === c ? !1 : c;
    c = null == a ? a : oe(a) ? "string" === typeof a ? ue(a) : c ? ve(a) : we(a) : void 0;
    return c
}
function jf(a, c) {
    a = Re(a, c);
    return null == a || "string" === typeof a ? a : void 0
}
function kf(a, c) {
    return qe(Re(a, c))
}
function lf(a, c) {
    return null != a ? a : c
}
function mf(a, c, d) {
    return lf(Ye(a, c), void 0 === d ? !1 : d)
}
function nf(a, c, d) {
    d = void 0 === d ? 0 : d;
    return lf(se(Re(a, c)), d)
}
function of(a, c, d) {
    return lf(jf(a, c), void 0 === d ? "" : d)
}
function pf(a, c) {
    var d = 0;
    d = void 0 === d ? 0 : d;
    return lf(kf(a, c), d)
}
function J(a, c, d) {
    if (null != d && "boolean" !== typeof d)
        throw Error("B`" + za(d) + "`" + d);
    return Te(a, c, d)
}
function qf(a, c, d) {
    return Te(a, c, null == d ? d : re(d))
}
function K(a, c, d) {
    return Te(a, c, te(d))
}
function M(a, c, d) {
    if (null != d && "string" !== typeof d)
        throw Error();
    return Te(a, c, d)
}
function N(a, c, d) {
    return Te(a, c, null == d ? d : pe(d))
}
;function O(a, c, d) {
    this.G = G(a, c, d)
}
v = O.prototype;
v.toJSON = function() {
    return Ud ? Le(this, this.G, !1) : Le(this, Je(this.G, Ne, void 0, void 0, !1), !0)
}
;
v.Z = function() {
    Ud = !0;
    try {
        return JSON.stringify(this.toJSON(), Fe)
    } finally {
        Ud = !1
    }
}
;
function rf(a, c) {
    a = c.g ? c.o(a, c.g, c.j, !0) : c.o(a, c.j, null, !0);
    return null === a ? void 0 : a
}
function sf(a) {
    var c = a.G;
    return Be(a.constructor, Pe(c, Ld(c), !1))
}
v.Ra = function() {
    return !!(Kd(this.G) & 2)
}
;
function tf(a, c, d) {
    c.g ? c.v(a, c.g, c.j, d, !0) : c.v(a, c.j, d, !0)
}
v.tb = Qd;
v.toString = function() {
    return Le(this, this.G, !1).toString()
}
;
function Le(a, c, d) {
    var e = Dc ? void 0 : a.constructor.ia;
    var f = Ld(d ? a.G : c);
    a = c.length;
    if (!a)
        return c;
    var g;
    if (Td(d = c[a - 1])) {
        a: {
            var h = d;
            var k = {}, l = !1, m;
            for (m in h) {
                var p = h[m];
                if (Array.isArray(p)) {
                    var r = p;
                    if (Vd(p, e, +m) || Sd(p) && 0 === p.size)
                        p = null;
                    p != r && (l = !0)
                }
                null != p ? k[m] = p : l = !0
            }
            if (l) {
                for (var u in k) {
                    h = k;
                    break a
                }
                h = null
            }
        }
        h != d && (g = !0);
        a--
    }
    for (m = +!!(f & 512) - 1; 0 < a; a--) {
        u = a - 1;
        d = c[u];
        u -= m;
        if (!(null == d || Vd(d, e, u) || Sd(d) && 0 === d.size))
            break;
        var w = !0
    }
    if (!g && !w)
        return c;
    c = Array.prototype.slice.call(c, 0, a);
    h && c.push(h);
    return c
}
;function uf(a, c) {
    this.j = a;
    this.g = c;
    this.o = H;
    this.v = I;
    this.defaultValue = void 0
}
;function vf(a) {
    if ("string" === typeof a)
        return {
            buffer: sd(a),
            Ra: !1
        };
    if (Array.isArray(a))
        return {
            buffer: new Uint8Array(a),
            Ra: !1
        };
    if (a.constructor === Uint8Array)
        return {
            buffer: a,
            Ra: !1
        };
    if (a.constructor === ArrayBuffer)
        return {
            buffer: new Uint8Array(a),
            Ra: !1
        };
    if (a.constructor === xd)
        return {
            buffer: Ad(a) || ud || (ud = new Uint8Array(0)),
            Ra: !0
        };
    if (a instanceof Uint8Array)
        return {
            buffer: new Uint8Array(a.buffer,a.byteOffset,a.byteLength),
            Ra: !1
        };
    throw Error("L");
}
;function wf(a, c) {
    this.o = null;
    this.A = !1;
    this.g = this.j = this.v = 0;
    this.init(a, void 0, void 0, c)
}
wf.prototype.init = function(a, c, d, e) {
    e = void 0 === e ? {} : e;
    this.Ab = void 0 === e.Ab ? !1 : e.Ab;
    a && (a = vf(a),
    this.o = a.buffer,
    this.A = a.Ra,
    this.v = c || 0,
    this.j = void 0 !== d ? this.v + d : this.o.length,
    this.g = this.v)
}
;
wf.prototype.clear = function() {
    this.o = null;
    this.A = !1;
    this.g = this.j = this.v = 0;
    this.Ab = !1
}
;
wf.prototype.reset = function() {
    this.g = this.v
}
;
function xf(a, c) {
    a.g = c;
    if (c > a.j)
        throw Error("J`" + c + "`" + a.j);
}
function yf(a) {
    var c = a.o
      , d = a.g
      , e = c[d++]
      , f = e & 127;
    if (e & 128 && (e = c[d++],
    f |= (e & 127) << 7,
    e & 128 && (e = c[d++],
    f |= (e & 127) << 14,
    e & 128 && (e = c[d++],
    f |= (e & 127) << 21,
    e & 128 && (e = c[d++],
    f |= e << 28,
    e & 128 && c[d++] & 128 && c[d++] & 128 && c[d++] & 128 && c[d++] & 128 && c[d++] & 128)))))
        throw Error("I");
    xf(a, d);
    return f
}
var zf = [];
function Af(a, c) {
    if (zf.length) {
        var d = zf.pop();
        d.init(a, void 0, void 0, c);
        a = d
    } else
        a = new wf(a,c);
    this.g = a;
    this.o = this.g.g;
    this.j = this.v = -1;
    Bf(this, c)
}
function Bf(a, c) {
    c = void 0 === c ? {} : c;
    a.Wb = void 0 === c.Wb ? !1 : c.Wb
}
Af.prototype.reset = function() {
    this.g.reset();
    this.o = this.g.g;
    this.j = this.v = -1
}
;
function Cf(a) {
    var c = a.g;
    if (c.g == c.j)
        return !1;
    a.o = a.g.g;
    var d = yf(a.g) >>> 0;
    c = d >>> 3;
    d &= 7;
    if (!(0 <= d && 5 >= d))
        throw Error("E`" + d + "`" + a.o);
    if (1 > c)
        throw Error("F`" + c + "`" + a.o);
    a.v = c;
    a.j = d;
    return !0
}
function Df(a) {
    switch (a.j) {
    case 0:
        if (0 != a.j)
            Df(a);
        else
            a: {
                a = a.g;
                for (var c = a.g, d = c + 10, e = a.o; c < d; )
                    if (0 === (e[c++] & 128)) {
                        xf(a, c);
                        break a
                    }
                throw Error("I");
            }
        break;
    case 1:
        a = a.g;
        xf(a, a.g + 8);
        break;
    case 2:
        2 != a.j ? Df(a) : (c = yf(a.g) >>> 0,
        a = a.g,
        xf(a, a.g + c));
        break;
    case 5:
        a = a.g;
        xf(a, a.g + 4);
        break;
    case 3:
        c = a.v;
        do {
            if (!Cf(a))
                throw Error("G");
            if (4 == a.j) {
                if (a.v != c)
                    throw Error("H");
                break
            }
            Df(a)
        } while (1);
        break;
    default:
        throw Error("E`" + a.j + "`" + a.o);
    }
}
function Ef(a, c, d) {
    var e = a.g.j
      , f = yf(a.g) >>> 0
      , g = a.g.g + f
      , h = g - e;
    0 >= h && (a.g.j = g,
    d(c, a, void 0, void 0, void 0),
    h = g - a.g.g);
    if (h)
        throw Error("D`" + f + "`" + (f - h));
    a.g.g = g;
    a.g.j = e
}
var Ff = [];
function Gf(a, c, d) {
    this.Nb = a;
    this.g = c;
    this.Dc = d
}
;var Hf = Symbol();
function If(a) {
    var c = a[Hf];
    if (!c) {
        var d = Jf(a)
          , e = Kf(a)
          , f = e.o;
        c = f ? function(g, h) {
            return f(g, h, e)
        }
        : function(g, h) {
            for (; Cf(h) && 4 != h.j; ) {
                var k = h.v
                  , l = e[k];
                if (!l) {
                    var m = e.tc;
                    m && (m = m[k]) && (l = e[k] = Lf(m))
                }
                if (!l || !l(h, g, k)) {
                    k = h;
                    l = k.o;
                    Df(k);
                    m = k;
                    if (m.Wb)
                        l = void 0;
                    else {
                        k = m.g.g - l;
                        m.g.g = l;
                        m = m.g;
                        if (0 == k)
                            k = wd || (wd = new xd(null,vd));
                        else {
                            if (0 > k)
                                throw Error("K`" + k);
                            l = m.g;
                            var p = l + k;
                            if (p > m.j)
                                throw Error("J`" + (m.j - l) + "`" + k);
                            m.g = p;
                            m.Ab && m.A ? k = m.o.subarray(l, l + k) : (m = m.o,
                            k = l + k,
                            k = l === k ? ud || (ud = new Uint8Array(0)) : be ? m.slice(l, k) : new Uint8Array(m.subarray(l, k)));
                            k = 0 == k.length ? wd || (wd = new xd(null,vd)) : new xd(k,vd)
                        }
                        l = k
                    }
                    k = g;
                    l && (Zd || (Zd = Symbol()),
                    (m = k[Zd]) ? m.push(l) : k[Zd] = [l])
                }
            }
            d === Mf || d === Nf || d.v || (g[ae || (ae = Symbol())] = d)
        }
        ;
        a[Hf] = c
    }
    return c
}
function Lf(a) {
    a = Array.isArray(a) ? a[0]instanceof Gf ? a : [Of, a] : [a, void 0];
    var c = a[0].Nb;
    if (a = a[1]) {
        var d = If(a)
          , e = Kf(a).Jb;
        return function(f, g, h) {
            return c(f, g, h, e, d)
        }
    }
    return c
}
function Pf() {}
var Mf, Nf, Qf = Symbol();
function Rf(a, c, d) {
    var e = d[1];
    if (e) {
        var f = e[Qf];
        var g = f ? f.Jb : Ee(e[0]);
        a[c] = null != f ? f : e
    }
    g && g === Ce ? (a.g || (a.g = new Set)).add(c) : d[0] && (a.j || (a.j = new Set)).add(c)
}
function Sf(a, c) {
    return [a.g, !c || 0 < c[0] ? void 0 : c]
}
function Jf(a) {
    var c = a[Qf];
    if (c)
        return c;
    c = Tf(a, a[Qf] = new Pf, Sf, Sf, Rf);
    if (!c.tc && !c.j && !c.g) {
        var d = !0, e;
        for (e in c)
            isNaN(e) || (d = !1);
        d ? (Ee(a[0]) === Ce ? Nf ? c = Nf : (c = new Pf,
        c.Jb = Ee(!0),
        c = Nf = c) : c = Mf || (Mf = new Pf),
        c = a[Qf] = c) : c.v = !0
    }
    return c
}
function Uf(a, c, d) {
    a[c] = d
}
function Tf(a, c, d, e, f) {
    f = void 0 === f ? Uf : f;
    c.Jb = Ee(a[0]);
    var g = 0
      , h = a[++g];
    h && h.constructor === Object && (c.tc = h,
    h = a[++g],
    "function" === typeof h && (c.o = h,
    c.A = a[++g],
    h = a[++g]));
    for (var k = {}; Array.isArray(h) && "number" === typeof h[0] && 0 < h[0]; ) {
        for (var l = 0; l < h.length; l++)
            k[h[l]] = h;
        h = a[++g]
    }
    for (l = 1; void 0 !== h; ) {
        "number" === typeof h && (l += h,
        h = a[++g]);
        var m = void 0;
        if (h instanceof Gf)
            var p = h;
        else
            p = Vf,
            g--;
        if (p.Dc) {
            h = a[++g];
            m = a;
            var r = g;
            "function" == typeof h && (h = h(),
            m[r] = h);
            m = h
        }
        h = a[++g];
        r = l + 1;
        "number" === typeof h && 0 > h && (r -= h,
        h = a[++g]);
        for (; l < r; l++) {
            var u = k[l];
            f(c, l, m ? e(p, m, u) : d(p, u))
        }
    }
    return c
}
var Wf = Symbol()
  , Xf = Symbol();
function Yf(a, c) {
    var d = a.Nb;
    return c ? function(e, f, g) {
        return d(e, f, g, c)
    }
    : d
}
function Zf(a, c, d) {
    var e = a.Nb, f, g;
    return function(h, k, l) {
        return e(h, k, l, g || (g = Kf(c).Jb), f || (f = If(c)), d)
    }
}
function Kf(a) {
    var c = a[Xf];
    if (c)
        return c;
    Jf(a);
    c = Tf(a, a[Xf] = {}, Yf, Zf);
    Xf in a && Qf in a && Wf in a && (a.length = 0);
    return c
}
var $f;
$f = new Gf(function(a, c, d) {
    if (0 !== a.j)
        return !1;
    a = yf(a.g);
    Ue(c, Ld(c), d, a);
    return !0
}
,!1,!1);
var Of = new Gf(function(a, c, d, e, f) {
    if (2 !== a.j)
        return !1;
    Ef(a, df(c, e, d, !0), f);
    return !0
}
,!1,!0), Vf = new Gf(function(a, c, d, e, f) {
    if (2 !== a.j)
        return !1;
    Ef(a, df(c, e, d), f);
    return !0
}
,!1,!0), ag;
ag = new Gf(function(a, c, d, e, f) {
    if (2 !== a.j)
        return !1;
    e = G(void 0, e[0], e[1]);
    var g = Ld(c);
    Yd(g);
    var h = Xe(c, g, d, 3);
    g = Ld(c);
    Kd(h) & 4 && (h = Dd(h),
    Md(h, (Kd(h) | 1) & -2079),
    Ue(c, g, d, h));
    h.push(e);
    Ef(a, e, f);
    return !0
}
,!0,!0);
var bg;
bg = new Gf(function(a, c, d) {
    if (0 !== a.j)
        return !1;
    a = yf(a.g);
    Ue(c, Ld(c), d, a);
    return !0
}
,!1,!1);
var cg;
cg = new Gf(function(a, c, d) {
    if (0 !== a.j && 2 !== a.j)
        return !1;
    c = Xe(c, Ld(c), d, 2, !1);
    if (2 == a.j)
        for (d = yf(a.g) >>> 0,
        d = a.g.g + d; a.g.g < d; )
            c.push(yf(a.g));
    else
        c.push(yf(a.g));
    return !0
}
,!0,!1);
function dg(a) {
    return function(c) {
        if (null == c || "" == c)
            c = new a;
        else {
            c = JSON.parse(c);
            if (!Array.isArray(c))
                throw Error(void 0);
            Hd(c, 32);
            c = Be(a, c)
        }
        return c
    }
}
;function eg(a) {
    this.G = G(a)
}
y(eg, O);
function fg(a) {
    this.G = G(a, 0, "xsrf")
}
y(fg, O);
fg.prototype.Ca = function() {
    return jf(this, 1)
}
;
function gg(a) {
    this.G = G(a, 1)
}
y(gg, O);
var hg = new uf(48448350,fg);
function ig(a) {
    if (!a)
        return "";
    if (/^about:(?:blank|srcdoc)$/.test(a))
        return window.origin || "";
    0 === a.indexOf("blob:") && (a = a.substring(5));
    a = a.split("#")[0].split("?")[0];
    a = a.toLowerCase();
    0 == a.indexOf("//") && (a = window.location.protocol + a);
    /^[\w\-]*:\/\//.test(a) || (a = window.location.href);
    var c = a.substring(a.indexOf("://") + 3)
      , d = c.indexOf("/");
    -1 != d && (c = c.substring(0, d));
    d = a.substring(0, a.indexOf("://"));
    if (!d)
        throw Error("M`" + a);
    if ("http" !== d && "https" !== d && "chrome-extension" !== d && "moz-extension" !== d && "file" !== d && "android-app" !== d && "chrome-search" !== d && "chrome-untrusted" !== d && "chrome" !== d && "app" !== d && "devtools" !== d)
        throw Error("N`" + d);
    a = "";
    var e = c.indexOf(":");
    if (-1 != e) {
        var f = c.substring(e + 1);
        c = c.substring(0, e);
        if ("http" === d && "80" !== f || "https" === d && "443" !== f)
            a = ":" + f
    }
    return d + "://" + c + a
}
;function jg(a) {
    this.G = G(a)
}
y(jg, O);
function kg() {}
;function lg(a, c) {
    this.o = a;
    this.v = c;
    this.j = 0;
    this.g = null
}
lg.prototype.get = function() {
    if (0 < this.j) {
        this.j--;
        var a = this.g;
        this.g = a.next;
        a.next = null
    } else
        a = this.o();
    return a
}
;
lg.prototype.put = function(a) {
    this.v(a);
    100 > this.j && (this.j++,
    a.next = this.g,
    this.g = a)
}
;
var mg = []
  , ng = []
  , og = !1;
function pg(a) {
    mg[mg.length] = a;
    if (og)
        for (var c = 0; c < ng.length; c++)
            a(A(ng[c].g, ng[c]))
}
;function qg() {
    return null
}
function rg() {}
function sg(a) {
    var c = c || 0;
    return function() {
        return a.apply(this, Array.prototype.slice.call(arguments, 0, c))
    }
}
;function tg(a, c, d) {
    for (var e in a)
        c.call(d, a[e], e, a)
}
function ug(a, c) {
    var d = {}, e;
    for (e in a)
        d[e] = c.call(void 0, a[e], e, a);
    return d
}
function vg(a) {
    var c = [], d = 0, e;
    for (e in a)
        c[d++] = a[e];
    return c
}
function wg(a) {
    var c = [], d = 0, e;
    for (e in a)
        c[d++] = e;
    return c
}
function xg(a, c) {
    return null !== a && c in a
}
function yg(a) {
    for (var c in a)
        return !1;
    return !0
}
function zg(a) {
    var c = {}, d;
    for (d in a)
        c[d] = a[d];
    return c
}
var Ag = "constructor hasOwnProperty isPrototypeOf propertyIsEnumerable toLocaleString toString valueOf".split(" ");
function Bg(a, c) {
    for (var d, e, f = 1; f < arguments.length; f++) {
        e = arguments[f];
        for (d in e)
            a[d] = e[d];
        for (var g = 0; g < Ag.length; g++)
            d = Ag[g],
            Object.prototype.hasOwnProperty.call(e, d) && (a[d] = e[d])
    }
}
function Cg(a) {
    var c = arguments.length;
    if (1 == c && Array.isArray(arguments[0]))
        return Cg.apply(null, arguments[0]);
    for (var d = {}, e = 0; e < c; e++)
        d[arguments[e]] = !0;
    return d
}
;var Dg;
var Eg = {};
function Fg(a) {
    this.g = a
}
Fg.prototype.toString = function() {
    return this.g.toString()
}
;
function Gg(a) {
    return a instanceof Fg && a.constructor === Fg ? a.g : "type_error:SafeHtml"
}
var Hg = new Fg(z.trustedTypes && z.trustedTypes.emptyHTML || "",Eg);
var Ig = function(a) {
    var c = !1, d;
    return function() {
        c || (d = a(),
        c = !0);
        return d
    }
}(function() {
    var a = document.createElement("div")
      , c = document.createElement("div");
    c.appendChild(document.createElement("div"));
    a.appendChild(c);
    c = a.firstChild.firstChild;
    a.innerHTML = Gg(Hg);
    return !c.parentElement
});
function Jg(a) {
    var c = {
        "&amp;": "&",
        "&lt;": "<",
        "&gt;": ">",
        "&quot;": '"'
    };
    var d = z.document.createElement("div");
    return a.replace(Kg, function(e, f) {
        var g = c[e];
        if (g)
            return g;
        "#" == f.charAt(0) && (f = Number("0" + f.slice(1)),
        isNaN(f) || (g = String.fromCharCode(f)));
        if (!g) {
            g = e + " ";
            if (void 0 === Dg) {
                f = null;
                var h = z.trustedTypes;
                if (h && h.createPolicy) {
                    try {
                        f = h.createPolicy("goog#html", {
                            createHTML: La,
                            createScript: La,
                            createScriptURL: La
                        })
                    } catch (k) {
                        z.console && z.console.error(k.message)
                    }
                    Dg = f
                } else
                    Dg = f
            }
            g = (f = Dg) ? f.createHTML(g) : g;
            g = new Fg(g,Eg);
            if (Ig())
                for (; d.lastChild; )
                    d.removeChild(d.lastChild);
            d.innerHTML = Gg(g);
            g = d.firstChild.nodeValue.slice(0, -1)
        }
        return c[e] = g
    })
}
function Lg(a) {
    return a.replace(/&([^;]+);/g, function(c, d) {
        switch (d) {
        case "amp":
            return "&";
        case "lt":
            return "<";
        case "gt":
            return ">";
        case "quot":
            return '"';
        default:
            return "#" != d.charAt(0) || (d = Number("0" + d.slice(1)),
            isNaN(d)) ? c : String.fromCharCode(d)
        }
    })
}
var Kg = /&([^;\s<&]+);?/g;
function Mg(a) {
    return null == a ? "" : String(a)
}
function Ng(a) {
    return a.replace(RegExp("(^|[\\s]+)([a-z])", "g"), function(c, d, e) {
        return d + e.toUpperCase()
    })
}
;function Og() {
    var a = document;
    var c = "IFRAME";
    "application/xhtml+xml" === a.contentType && (c = c.toLowerCase());
    return a.createElement(c)
}
function Pg() {
    this.g = z.document || document
}
;var Qg;
function Rg() {
    var a = z.MessageChannel;
    "undefined" === typeof a && "undefined" !== typeof window && window.postMessage && window.addEventListener && !E("Presto") && (a = function() {
        var f = Og();
        f.style.display = "none";
        document.documentElement.appendChild(f);
        var g = f.contentWindow;
        f = g.document;
        f.open();
        f.close();
        var h = "callImmediate" + Math.random()
          , k = "file:" == g.location.protocol ? "*" : g.location.protocol + "//" + g.location.host;
        f = A(function(l) {
            if (("*" == k || l.origin == k) && l.data == h)
                this.port1.onmessage()
        }, this);
        g.addEventListener("message", f, !1);
        this.port1 = {};
        this.port2 = {
            postMessage: function() {
                g.postMessage(h, k)
            }
        }
    }
    );
    if ("undefined" !== typeof a && !(Ic() ? 0 : E("Trident") || E("MSIE"))) {
        var c = new a
          , d = {}
          , e = d;
        c.port1.onmessage = function() {
            if (void 0 !== d.next) {
                d = d.next;
                var f = d.oc;
                d.oc = null;
                f()
            }
        }
        ;
        return function(f) {
            e.next = {
                oc: f
            };
            e = e.next;
            c.port2.postMessage(0)
        }
    }
    return function(f) {
        z.setTimeout(f, 0)
    }
}
function Sg(a) {
    return a
}
pg(function(a) {
    Sg = a
});
function Tg() {
    this.j = this.g = null
}
Tg.prototype.add = function(a, c) {
    var d = Ug.get();
    d.set(a, c);
    this.j ? this.j.next = d : this.g = d;
    this.j = d
}
;
function Vg() {
    var a = Wg
      , c = null;
    a.g && (c = a.g,
    a.g = a.g.next,
    a.g || (a.j = null),
    c.next = null);
    return c
}
var Ug = new lg(function() {
    return new Xg
}
,function(a) {
    return a.reset()
}
);
function Xg() {
    this.next = this.scope = this.g = null
}
Xg.prototype.set = function(a, c) {
    this.g = a;
    this.scope = c;
    this.next = null
}
;
Xg.prototype.reset = function() {
    this.next = this.scope = this.g = null
}
;
var Yg, Zg = !1, Wg = new Tg;
function $g(a, c) {
    Yg || ah();
    Zg || (Yg(),
    Zg = !0);
    Wg.add(a, c)
}
function ah() {
    if (z.Promise && z.Promise.resolve) {
        var a = z.Promise.resolve(void 0);
        Yg = function() {
            a.then(bh)
        }
    } else
        Yg = function() {
            var c = bh;
            c = Sg(c);
            "function" !== typeof z.setImmediate || z.Window && z.Window.prototype && (Ic() || !E("Edge")) && z.Window.prototype.setImmediate == z.setImmediate ? (Qg || (Qg = Rg()),
            Qg(c)) : z.setImmediate(c)
        }
}
function bh() {
    for (var a; a = Vg(); ) {
        try {
            a.g.call(a.scope)
        } catch (c) {
            kc(c)
        }
        Ug.put(a)
    }
    Zg = !1
}
;function ch(a) {
    if (!a)
        return !1;
    try {
        return !!a.$goog_Thenable
    } catch (c) {
        return !1
    }
}
;function dh(a, c) {
    this.g = 0;
    this.B = void 0;
    this.v = this.j = this.o = null;
    this.A = this.C = !1;
    if (a != rg)
        try {
            var d = this;
            a.call(c, function(e) {
                eh(d, 2, e)
            }, function(e) {
                eh(d, 3, e)
            })
        } catch (e) {
            eh(this, 3, e)
        }
}
function fh() {
    this.next = this.o = this.j = this.A = this.g = null;
    this.v = !1
}
fh.prototype.reset = function() {
    this.o = this.j = this.A = this.g = null;
    this.v = !1
}
;
var gh = new lg(function() {
    return new fh
}
,function(a) {
    a.reset()
}
);
function hh(a, c, d) {
    var e = gh.get();
    e.A = a;
    e.j = c;
    e.o = d;
    return e
}
function ih(a) {
    if (a instanceof dh)
        return a;
    var c = new dh(rg);
    eh(c, 2, a);
    return c
}
function jh(a) {
    return new dh(function(c, d) {
        d(a)
    }
    )
}
function kh(a, c, d) {
    lh(a, c, d, null) || $g(Ia(c, a))
}
function mh(a) {
    return new dh(function(c, d) {
        var e = a.length
          , f = [];
        if (e)
            for (var g = function(m, p) {
                e--;
                f[m] = p;
                0 == e && c(f)
            }, h = function(m) {
                d(m)
            }, k = 0, l; k < a.length; k++)
                l = a[k],
                kh(l, Ia(g, k), h);
        else
            c(f)
    }
    )
}
function nh(a) {
    return new dh(function(c) {
        var d = a.length
          , e = [];
        if (d)
            for (var f = function(k, l, m) {
                d--;
                e[k] = l ? {
                    Uc: !0,
                    value: m
                } : {
                    Uc: !1,
                    reason: m
                };
                0 == d && c(e)
            }, g = 0, h; g < a.length; g++)
                h = a[g],
                kh(h, Ia(f, g, !0), Ia(f, g, !1));
        else
            c(e)
    }
    )
}
function oh() {
    var a, c, d = new dh(function(e, f) {
        a = e;
        c = f
    }
    );
    return new ph(d,a,c)
}
dh.prototype.then = function(a, c, d) {
    return qh(this, "function" === typeof a ? a : null, "function" === typeof c ? c : null, d)
}
;
dh.prototype.$goog_Thenable = !0;
function rh(a, c) {
    c = hh(c, c);
    c.v = !0;
    sh(a, c)
}
v = dh.prototype;
v.Aa = function(a, c) {
    return qh(this, null, a, c)
}
;
v.catch = dh.prototype.Aa;
v.cancel = function(a) {
    if (0 == this.g) {
        var c = new th(a);
        $g(function() {
            uh(this, c)
        }, this)
    }
}
;
function uh(a, c) {
    if (0 == a.g)
        if (a.o) {
            var d = a.o;
            if (d.j) {
                for (var e = 0, f = null, g = null, h = d.j; h && (h.v || (e++,
                h.g == a && (f = h),
                !(f && 1 < e))); h = h.next)
                    f || (g = h);
                f && (0 == d.g && 1 == e ? uh(d, c) : (g ? (e = g,
                e.next == d.v && (d.v = e),
                e.next = e.next.next) : vh(d),
                wh(d, f, 3, c)))
            }
            a.o = null
        } else
            eh(a, 3, c)
}
function sh(a, c) {
    a.j || 2 != a.g && 3 != a.g || xh(a);
    a.v ? a.v.next = c : a.j = c;
    a.v = c
}
function qh(a, c, d, e) {
    var f = hh(null, null, null);
    f.g = new dh(function(g, h) {
        f.A = c ? function(k) {
            try {
                var l = c.call(e, k);
                g(l)
            } catch (m) {
                h(m)
            }
        }
        : g;
        f.j = d ? function(k) {
            try {
                var l = d.call(e, k);
                void 0 === l && k instanceof th ? h(k) : g(l)
            } catch (m) {
                h(m)
            }
        }
        : h
    }
    );
    f.g.o = a;
    sh(a, f);
    return f.g
}
v.qd = function(a) {
    this.g = 0;
    eh(this, 2, a)
}
;
v.rd = function(a) {
    this.g = 0;
    eh(this, 3, a)
}
;
function eh(a, c, d) {
    0 == a.g && (a === d && (c = 3,
    d = new TypeError("P")),
    a.g = 1,
    lh(d, a.qd, a.rd, a) || (a.B = d,
    a.g = c,
    a.o = null,
    xh(a),
    3 != c || d instanceof th || yh(a, d)))
}
function lh(a, c, d, e) {
    if (a instanceof dh)
        return sh(a, hh(c || rg, d || null, e)),
        !0;
    if (ch(a))
        return a.then(c, d, e),
        !0;
    if (Ca(a))
        try {
            var f = a.then;
            if ("function" === typeof f)
                return zh(a, f, c, d, e),
                !0
        } catch (g) {
            return d.call(e, g),
            !0
        }
    return !1
}
function zh(a, c, d, e, f) {
    function g(l) {
        k || (k = !0,
        e.call(f, l))
    }
    function h(l) {
        k || (k = !0,
        d.call(f, l))
    }
    var k = !1;
    try {
        c.call(a, h, g)
    } catch (l) {
        g(l)
    }
}
function xh(a) {
    a.C || (a.C = !0,
    $g(a.Oc, a))
}
function vh(a) {
    var c = null;
    a.j && (c = a.j,
    a.j = c.next,
    c.next = null);
    a.j || (a.v = null);
    return c
}
v.Oc = function() {
    for (var a; a = vh(this); )
        wh(this, a, this.g, this.B);
    this.C = !1
}
;
function wh(a, c, d, e) {
    if (3 == d && c.j && !c.v)
        for (; a && a.A; a = a.o)
            a.A = !1;
    if (c.g)
        c.g.o = null,
        Ah(c, d, e);
    else
        try {
            c.v ? c.A.call(c.o) : Ah(c, d, e)
        } catch (f) {
            Bh.call(null, f)
        }
    gh.put(c)
}
function Ah(a, c, d) {
    2 == c ? a.A.call(a.o, d) : a.j && a.j.call(a.o, d)
}
function yh(a, c) {
    a.A = !0;
    $g(function() {
        a.A && Bh.call(null, c)
    })
}
var Bh = kc;
function th(a) {
    tb.call(this, a);
    this.g = !1
}
Ka(th, tb);
th.prototype.name = "cancel";
function ph(a, c, d) {
    this.promise = a;
    this.resolve = c;
    this.reject = d
}
;/*

 Copyright 2005, 2007 Bob Ippolito. All Rights Reserved.
 Copyright The Closure Library Authors.
 SPDX-License-Identifier: MIT
*/
function Ch(a, c) {
    this.A = [];
    this.P = a;
    this.I = c || null;
    this.v = this.g = !1;
    this.o = void 0;
    this.H = this.S = this.B = !1;
    this.C = 0;
    this.j = null;
    this.D = 0
}
Ka(Ch, kg);
v = Ch.prototype;
v.cancel = function(a) {
    if (this.g)
        this.o instanceof Ch && this.o.cancel();
    else {
        if (this.j) {
            var c = this.j;
            delete this.j;
            a ? c.cancel(a) : (c.D--,
            0 >= c.D && c.cancel())
        }
        this.P ? this.P.call(this.I, this) : this.H = !0;
        this.g || this.yb(new Dh(this))
    }
}
;
v.pc = function(a, c) {
    this.B = !1;
    Eh(this, a, c)
}
;
function Eh(a, c, d) {
    a.g = !0;
    a.o = d;
    a.v = !c;
    Fh(a)
}
function Gh(a) {
    if (a.g) {
        if (!a.H)
            throw new Hh(a);
        a.H = !1
    }
}
v.qa = function(a) {
    Gh(this);
    Eh(this, !0, a)
}
;
v.yb = function(a) {
    Gh(this);
    Eh(this, !1, a)
}
;
function Ih(a) {
    throw a;
}
function Jh(a, c, d) {
    return Kh(a, c, null, d)
}
function Lh(a, c, d) {
    Kh(a, c, function(e) {
        var f = c.call(this, e);
        if (void 0 === f)
            throw e;
        return f
    }, d)
}
function Kh(a, c, d, e) {
    a.A.push([c, d, e]);
    a.g && Fh(a);
    return a
}
v.then = function(a, c, d) {
    var e, f, g = new dh(function(h, k) {
        f = h;
        e = k
    }
    );
    Kh(this, f, function(h) {
        h instanceof Dh ? g.cancel() : e(h);
        return Mh
    }, this);
    return g.then(a, c, d)
}
;
Ch.prototype.$goog_Thenable = !0;
function Nh(a) {
    return Sc(a.A, function(c) {
        return "function" === typeof c[1]
    })
}
var Mh = {};
function Fh(a) {
    if (a.C && a.g && Nh(a)) {
        var c = a.C
          , d = Oh[c];
        d && (z.clearTimeout(d.g),
        delete Oh[c]);
        a.C = 0
    }
    a.j && (a.j.D--,
    delete a.j);
    c = a.o;
    for (var e = d = !1; a.A.length && !a.B; ) {
        var f = a.A.shift()
          , g = f[0]
          , h = f[1];
        f = f[2];
        if (g = a.v ? h : g)
            try {
                var k = g.call(f || a.I, c);
                k === Mh && (k = void 0);
                void 0 !== k && (a.v = a.v && (k == c || k instanceof Error),
                a.o = c = k);
                if (ch(c) || "function" === typeof z.Promise && c instanceof z.Promise)
                    e = !0,
                    a.B = !0
            } catch (l) {
                c = l,
                a.v = !0,
                Nh(a) || (d = !0)
            }
    }
    a.o = c;
    e && (k = A(a.pc, a, !0),
    e = A(a.pc, a, !1),
    c instanceof Ch ? (Kh(c, k, e),
    c.S = !0) : c.then(k, e));
    d && (c = new Ph(c),
    Oh[c.g] = c,
    a.C = c.g)
}
function Qh(a) {
    var c = new Ch;
    c.qa(a);
    return c
}
function Hh() {
    tb.call(this)
}
Ka(Hh, tb);
Hh.prototype.message = "Deferred has already fired";
Hh.prototype.name = "AlreadyCalledError";
function Dh() {
    tb.call(this)
}
Ka(Dh, tb);
Dh.prototype.message = "Deferred was canceled";
Dh.prototype.name = "CanceledError";
function Ph(a) {
    this.g = z.setTimeout(A(this.o, this), 0);
    this.j = a
}
Ph.prototype.o = function() {
    delete Oh[this.g];
    Ih(this.j)
}
;
var Oh = {};
function Rh(a, c) {
    this.j = c;
    this.g = a;
    Wa(this);
    Xa(this, Error(this))
}
y(Rh, db);
ea.Object.defineProperties(Rh.prototype, {
    error: {
        configurable: !0,
        enumerable: !0,
        get: function() {
            var a = Error()
              , c = this.N;
            a.fileName = c.fileName;
            a.lineNumber = c.lineNumber;
            a.columnNumber = c.columnNumber;
            a.message = c.message;
            a.name = c.name;
            a.stack = c.stack;
            a.toSource = c.toSource;
            a.cause = c.cause;
            for (var d in c)
                0 != d.indexOf("__java$") && (a[d] = c[d]);
            return a
        }
    }
});
function Sh(a) {
    return new dh(function(c, d) {
        Th(a, function(e) {
            c(e)
        }, function(e) {
            e || (e = new Rh("Q",null),
            Xa(e, Error(e)));
            d(e)
        })
    }
    )
}
;function Uh() {}
y(Uh, B);
function Vh() {
    this.g = !1
}
y(Vh, B);
Vh.prototype.X = function() {
    this.g || (this.g = !0,
    this.K())
}
;
Vh.prototype.wa = q("g");
function Wh(a, c) {
    c && !c.wa() && (a.wa() ? c.X() : (a.D || (a.D = []),
    a.D.push(c)))
}
Vh.prototype.K = function() {
    if (this.D) {
        var a = this.D;
        for (var c = 0; c < a.length; c++)
            a[c].X();
        this.D.length = 0
    }
}
;
Vh.prototype.toString = function() {
    return B.prototype.toString.call(this) || ""
}
;
function Xh() {
    this.g = !1;
    this.j = 1;
    this.v = this.o = !1;
    this.C = [];
    this.B = []
}
y(Xh, Vh);
function Yh(a, c) {
    Zh(4 != a.j, "R");
    Zh(1 == a.j, "S");
    var d = new Uh;
    d.g = c;
    a.F = d;
    $h(a, !0)
}
function ai(a, c) {
    Zh(4 != a.j, "R");
    Zh(1 == a.j, "S");
    a.L = c;
    $h(a, !1)
}
function Th(a, c, d) {
    Zh(4 != a.j, "T");
    if (a.o) {
        if (a.v)
            throw sb("U", a.A).N;
        throw sb("V", a.A).N;
    }
    if (1 != a.j) {
        a.o = !0;
        a.v = !0;
        try {
            2 == a.j && c ? c(a.F.g) : 3 == a.j && d && d(a.L)
        } catch (f) {
            var e = Za(f);
            (new bi).g(e);
            a.A || (a.A = e);
            throw e.N;
        } finally {
            a.v = !1
        }
        a.o = !1;
        e = !0
    } else
        e = !1;
    e || (c && a.C.push(c),
    d && a.B.push(d))
}
Xh.prototype.transform = function(a) {
    var c = new Xh;
    Th(this, function(d) {
        try {
            var e = a(d)
        } catch (f) {
            d = Za(f);
            ai(c, d);
            return
        }
        Yh(c, e)
    }, function(d) {
        ai(c, d)
    });
    return c
}
;
function ci(a, c) {
    var d = new Xh;
    Th(a.transform(c), function(e) {
        Th(e, function(f) {
            Yh(d, f)
        }, function(f) {
            ai(d, f)
        })
    }, function(e) {
        ai(d, e)
    });
    return d
}
Xh.prototype.K = function() {
    this.L = this.F = null;
    this.j = 4;
    this.C.length = 0;
    this.B.length = 0;
    Vh.prototype.K.call(this)
}
;
function $h(a, c) {
    a.o = !0;
    a.v = !0;
    try {
        if (c) {
            a.j = 2;
            var d = a.C;
            for (var e = 0; e < d.length; e++)
                (0,
                d[e])(a.F.g)
        } else
            for (a.j = 3,
            e = a.B,
            d = 0; d < e.length; d++)
                (0,
                e[d])(a.L)
    } catch (g) {
        var f = Za(g);
        (new bi).g(f);
        a.A || (a.A = f);
        throw f.N;
    } finally {
        a.v = !1
    }
    a.o = !1;
    a.C.length = 0;
    a.B.length = 0
}
;function Zh(a, c) {
    if (!a)
        throw rb(C(c)).N;
}
;function di(a, c) {
    if (null == c)
        for (c = 0; c < a.length; c = c + 1 | 0) {
            if (null == a[c])
                return c
        }
    else
        for (var d = 0; d < a.length; d = d + 1 | 0)
            if (Xb(c, a[d]))
                return d;
    return -1
}
;function ei(a) {
    if (null == a)
        throw a = new Mb,
        Va(a, "can't identity hash null"),
        Xa(a, new TypeError(a)),
        a.N;
    return ":" + ac(a)
}
;function fi(a, c) {
    for (var d = 0, e = c.length; d < e; d = d + 1 | 0)
        a.push(c[d])
}
;function gi() {}
y(gi, B);
gi.prototype.g = function(a) {
    this.j(a)
}
;
function hi(a, c, d, e, f, g, h) {
    var k = "";
    a && (k += a + ":");
    d && (k += "//",
    c && (k += c + "@"),
    k += d,
    e && (k += ":" + e));
    f && (k += f);
    g && (k += "?" + g);
    h && (k += "#" + h);
    return k
}
var ii = RegExp("^(?:([^:/?#.]+):)?(?://(?:([^\\\\/?#]*)@)?([^\\\\/?#]*?)(?::([0-9]+))?(?=[\\\\/?#]|$))?([^?#]+)?(?:\\?([^#]*))?(?:#([\\s\\S]*))?$");
function ji(a) {
    return a.match(ii)
}
function ki(a) {
    return a ? decodeURI(a) : a
}
function li(a) {
    var c = a.indexOf("#");
    return 0 > c ? a : a.slice(0, c)
}
function mi(a, c) {
    if (a) {
        a = a.split("&");
        for (var d = 0; d < a.length; d++) {
            var e = a[d].indexOf("=")
              , f = null;
            if (0 <= e) {
                var g = a[d].substring(0, e);
                f = a[d].substring(e + 1)
            } else
                g = a[d];
            c(g, f ? decodeURIComponent(f.replace(/\+/g, " ")) : "")
        }
    }
}
function ni(a, c) {
    if (!c)
        return a;
    var d = a.indexOf("#");
    0 > d && (d = a.length);
    var e = a.indexOf("?");
    if (0 > e || e > d) {
        e = d;
        var f = ""
    } else
        f = a.substring(e + 1, d);
    a = [a.slice(0, e), f, a.slice(d)];
    d = a[1];
    a[1] = c ? d ? d + "&" + c : c : d;
    return a[0] + (a[1] ? "?" + a[1] : "") + a[2]
}
function oi(a, c, d) {
    if (Array.isArray(c))
        for (var e = 0; e < c.length; e++)
            oi(a, String(c[e]), d);
    else
        null != c && d.push(a + ("" === c ? "" : "=" + encodeURIComponent(String(c))))
}
function pi(a, c) {
    var d = [];
    for (c = c || 0; c < a.length; c += 2)
        oi(a[c], a[c + 1], d);
    return d.join("&")
}
function qi(a) {
    var c = [], d;
    for (d in a)
        oi(d, a[d], c);
    return c.join("&")
}
function ri(a, c) {
    var d = 2 == arguments.length ? pi(arguments[1], 0) : pi(arguments, 1);
    return ni(a, d)
}
function si(a, c) {
    c = qi(c);
    return ni(a, c)
}
function ti(a, c, d) {
    d = null != d ? "=" + encodeURIComponent(String(d)) : "";
    return ni(a, c + d)
}
function ui(a, c, d, e) {
    for (var f = d.length; 0 <= (c = a.indexOf(d, c)) && c < e; ) {
        var g = a.charCodeAt(c - 1);
        if (38 == g || 63 == g)
            if (g = a.charCodeAt(c + f),
            !g || 61 == g || 38 == g || 35 == g)
                return c;
        c += f + 1
    }
    return -1
}
var vi = /#|$/;
function wi(a, c) {
    var d = a.search(vi)
      , e = ui(a, 0, c, d);
    if (0 > e)
        return null;
    var f = a.indexOf("&", e);
    if (0 > f || f > d)
        f = d;
    e += c.length + 1;
    return decodeURIComponent(a.slice(e, -1 !== f ? f : 0).replace(/\+/g, " "))
}
var xi = /[?&]($|#)/;
function yi(a, c) {
    for (var d = a.search(vi), e = 0, f, g = []; 0 <= (f = ui(a, e, c, d)); )
        g.push(a.substring(e, f)),
        e = Math.min(a.indexOf("&", f) + 1 || d, d);
    g.push(a.slice(e));
    return g.join("").replace(xi, "$1")
}
function zi(a, c) {
    var d = a.length - 1;
    0 <= d && a.indexOf("/", d) == d && (a = a.slice(0, -1));
    lc(c, "/") && (c = c.slice(1));
    return a + "/" + c
}
;function Ai(a) {
    var c = xa("window.location.href");
    null == a && (a = 'Unknown Error of type "null/undefined"');
    if ("string" === typeof a)
        return {
            message: a,
            name: "Unknown error",
            lineNumber: "Not available",
            fileName: c,
            stack: "Not available"
        };
    var d = !1;
    try {
        var e = a.lineNumber || a.line || "Not available"
    } catch (g) {
        e = "Not available",
        d = !0
    }
    try {
        var f = a.fileName || a.filename || a.sourceURL || z.$googDebugFname || c
    } catch (g) {
        f = "Not available",
        d = !0
    }
    c = Bi(a);
    return !d && a.lineNumber && a.fileName && a.stack && a.message && a.name ? {
        message: a.message,
        name: a.name,
        lineNumber: a.lineNumber,
        fileName: a.fileName,
        stack: c
    } : (d = a.message,
    null == d && (d = a.constructor && a.constructor instanceof Function ? 'Unknown Error of type "' + (a.constructor.name ? a.constructor.name : Ci(a.constructor)) + '"' : "Unknown Error of unknown type",
    "function" === typeof a.toString && Object.prototype.toString !== a.toString && (d += ": " + a.toString())),
    {
        message: d,
        name: a.name || "UnknownError",
        lineNumber: e,
        fileName: f,
        stack: c || "Not available"
    })
}
function Bi(a, c) {
    c || (c = {});
    c[Di(a)] = !0;
    var d = a.stack || "";
    (a = a.cause) && !c[Di(a)] && (d += "\nCaused by: ",
    a.stack && 0 == a.stack.indexOf(a.toString()) || (d += "string" === typeof a ? a : a.message + "\n"),
    d += Bi(a, c));
    return d
}
function Di(a) {
    var c = "";
    "function" === typeof a.toString && (c = "" + a);
    return c + a.stack
}
function Ei(a, c) {
    a instanceof Error || (a = Error(a),
    Error.captureStackTrace && Error.captureStackTrace(a, Ei));
    a.stack || (a.stack = Fi(Ei));
    if (c) {
        for (var d = 0; a["message" + d]; )
            ++d;
        a["message" + d] = String(c)
    }
    return a
}
function Gi(a, c) {
    a = Ei(a);
    if (c)
        for (var d in c)
            je(a, d, c[d]);
    return a
}
function Fi(a) {
    var c = Error();
    if (Error.captureStackTrace)
        Error.captureStackTrace(c, a || Fi),
        c = String(c.stack);
    else {
        try {
            throw c;
        } catch (d) {
            c = d
        }
        c = (c = c.stack) ? String(c) : null
    }
    c || (c = Hi(a || arguments.callee.caller, []));
    return c
}
function Hi(a, c) {
    var d = [];
    if (Tc(c, a))
        d.push("[...circular reference...]");
    else if (a && 50 > c.length) {
        d.push(Ci(a) + "(");
        for (var e = a.arguments, f = 0; e && f < e.length; f++) {
            0 < f && d.push(", ");
            var g = e[f];
            switch (typeof g) {
            case "object":
                g = g ? "object" : "null";
                break;
            case "string":
                break;
            case "number":
                g = String(g);
                break;
            case "boolean":
                g = g ? "true" : "false";
                break;
            case "function":
                g = (g = Ci(g)) ? g : "[fn]";
                break;
            default:
                g = typeof g
            }
            40 < g.length && (g = g.slice(0, 40) + "...");
            d.push(g)
        }
        c.push(a);
        d.push(")\n");
        try {
            d.push(Hi(a.caller, c))
        } catch (h) {
            d.push("[exception trying to get caller]\n")
        }
    } else
        a ? d.push("[...long stack...]") : d.push("[end]");
    return d.join("")
}
function Ci(a) {
    if (Ii[a])
        return Ii[a];
    a = String(a);
    if (!Ii[a]) {
        var c = /function\s+([^\(]+)/m.exec(a);
        Ii[a] = c ? c[1] : "[Anonymous]"
    }
    return Ii[a]
}
var Ii = {};
function Ji(a) {
    a && "function" == typeof a.X && a.X()
}
;function Ki(a) {
    for (var c = 0, d = arguments.length; c < d; ++c) {
        var e = arguments[c];
        Ba(e) ? Ki.apply(null, e) : Ji(e)
    }
}
;function Q() {
    this.L = this.L;
    this.C = this.C
}
Q.prototype.L = !1;
Q.prototype.wa = q("L");
Q.prototype.X = function() {
    this.L || (this.L = !0,
    this.K())
}
;
function R(a, c) {
    c = Ia(Ji, c);
    a.L ? c() : (a.C || (a.C = []),
    a.C.push(c))
}
Q.prototype.K = function() {
    if (this.C)
        for (; this.C.length; )
            this.C.shift()()
}
;
function Li() {
    this.clear()
}
var Mi;
function Ni(a) {
    var c = Oi()
      , d = c.g;
    if (d[0]) {
        var e = c.j;
        c = c.o ? e : -1;
        do
            c = (c + 1) % 0,
            a(d[c]);
        while (c !== e)
    }
}
Li.prototype.clear = function() {
    this.g = [];
    this.j = -1;
    this.o = !1
}
;
function Oi() {
    Mi || (Mi = new Li);
    return Mi
}
;function Pi() {
    Q.call(this);
    this.j = 0;
    this.g = null
}
y(Pi, Q);
Pi.prototype.init = function() {
    this.g = []
}
;
var Qi = new Pi;
function Ri(a) {
    this.e = a
}
;function bi() {}
y(bi, gi);
bi.prototype.j = function(a) {
    var c = a.g;
    a = a.N;
    if (a instanceof Object && !Object.isFrozen(a)) {
        var d = a.fileName || a.filename || a.sourceURL || z.$googDebugFname || location.href;
        d = d instanceof Location || d instanceof URL ? d.href : d;
        try {
            a.fileName = d
        } catch (e) {}
    }
    if (3 <= Qi.j)
        throw Error("X`" + c);
    Qi.j++;
    try {
        Qi.wa() || a instanceof Dh || a instanceof th || Qi.g && 10 > Qi.g.length && Qi.g.push(new Ri(a))
    } finally {
        Qi.j--
    }
}
;
function Si(a) {
    if (null == a)
        return "null";
    var c = typeof a;
    return "object" === c ? Array.isArray(a) ? "array" : c : c
}
;function Ti(a, c, d) {
    a[c] = void 0 !== d ? d : null
}
function Ui(a) {
    for (var c in a)
        return !1;
    return !0
}
function Vi(a) {
    var c = {}, d;
    for (d in a)
        c[d] = a[d];
    return c
}
;function Wi(a, c, d) {
    a[c] = Sb(d) ? d.g : null != d ? d : null
}
function Xi(a, c) {
    a = a[c];
    return null != a ? a : null
}
;function Yi(a) {
    var c = new Xh;
    Yh(c, a);
    return c
}
;function Zi(a) {
    this.G = G(a, 0, "docs.security.access_capabilities")
}
y(Zi, O);
var $i = dg(Zi);
function aj(a, c) {
    if (isObject(a, c))
        return !0;
    if (!a || !c)
        return !1;
    var d = a.length;
    if (d != c.length)
        return !1;
    for (var e = 0; e < d; e = e + 1 | 0)
        if (!bj(a, c, e))
            return !1;
    return !0
}
function bj(a, c, d) {
    var e = Si(a[d]);
    if (!isObject(e, Si(c[d])))
        return !1;
    switch (e) {
    case "null":
        return !0;
    case "boolean":
        return a[d] == c[d];
    case "number":
        return a[d] == c[d];
    case "string":
        return isObject(a[d], c[d]);
    case "array":
        return aj(a[d], c[d]);
    case "object":
        return cj(a[d], c[d]);
    default:
        throw D("Z`" + C(e)).N;
    }
}
function dj(a) {
    for (var c = [], d = 0; d < a.length; d = d + 1 | 0)
        c.push(a[d]);
    return c
}
;function ej(a, c, d) {
    var e = Si(a[d]);
    if (!isObject(e, Si(c[d])))
        return !1;
    switch (e) {
    case "null":
        return !0;
    case "boolean":
        return a[d] == c[d];
    case "number":
        return a[d] == c[d];
    case "string":
        return isObject(a[d], c[d]);
    case "object":
        return cj(a[d], c[d]);
    case "array":
        return aj(a[d], c[d]);
    default:
        throw D("$`" + C(e) + "`" + C(d)).N;
    }
}
function cj(a, c) {
    if (isObject(a, c))
        return !0;
    if (!a || !c)
        return !1;
    var d = Object.keys(a).length
      , e = Object.keys(c).length;
    if (d != e)
        return !1;
    for (e = 0; e < d; e = e + 1 | 0) {
        var f = Object.keys(a)[e];
        if (!ej(a, c, f))
            return !1
    }
    return !0
}
;function fj() {
    var a = a ? a : function(d) {
        return Kb(Math.floor(Math.random() * d))
    }
    ;
    var c = Ta(a(2147483647));
    c = C(gj("0", Math.max(0, 8 - c.length | 0))) + C(c);
    a = Ta(a(2147483647));
    return C(a) + C(c)
}
;var gj = String.prototype.repeat ? function(a, c) {
    return a.repeat(c)
}
: function(a, c) {
    return Array(c + 1).join(a)
}
;
function hj(a) {
    this.g = a
}
y(hj, B);
hj.prototype.getType = q("g");
function ij(a) {
    var c = new jj
      , d = [];
    for (var e = 0; e < a.length; e++)
        d.push(c.Z(a[e]));
    return d
}
;var kj = {
    Md: "build-label",
    vd: "buildLabel",
    wd: "clientLog",
    Ad: "docId",
    Od: "mobile-app-version",
    Vd: "severity",
    Yd: "severity-unprefixed",
    Gd: "isArrayPrototypeIntact",
    Jd: "isModuleLoadFailure",
    Ud: "reportName",
    Nd: "locale",
    yd: "createdOnServer",
    Qd: "numUnsavedCommands",
    zd: "cspViolationContext",
    Td: "relatedToBrowserExtension"
};
function lj(a) {
    this.g = a
}
y(lj, B);
lj.prototype.info = function(a, c, d) {
    this.g.info(a.N, c, d)
}
;
lj.prototype.log = function(a, c, d) {
    this.g.log(a.N, c, d)
}
;
function mj() {
    this.g = !1
}
y(mj, Vh);
mj.prototype.clear = n();
mj.prototype.log = n();
function nj() {
    nj = n();
    oj = Math.floor(-2147483648 * Math.random())
}
var oj = 0;
function pj(a) {
    this.o = a ? a : qj();
    this.g = {};
    this.A = new mj;
    this.j = {}
}
y(pj, B);
pj.prototype.B = function(a, c) {
    a = this.j = a;
    var d = [];
    for (var e in a)
        d.push([e, a[e]]);
    d.push(["ilc", Date.now() - c])
}
;
pj.prototype.C = function() {
    return JSON.stringify(this.j)
}
;
function rj(a, c, d) {
    var e = (nj(),
    oj);
    oj = oj + 1 | 0;
    e = "goog_" + e;
    var f = a.g;
    a.v && a.v.g(c);
    var g = new sj
      , h = a.o
      , k = a.o.g ? performance.now() : Date.now()
      , l = a.D
      , m = a.v;
    g.j = !1;
    g.D = 0;
    g.I = a;
    g.A = h;
    g.g = k;
    g.o = c;
    g.F = !0 === d;
    g.B = void 0;
    g.L = !1;
    g.C = l;
    g.v = m;
    Ti(f, e, g);
    return e
}
function tj(a, c) {
    var d = a.g[c];
    if (d) {
        var e = void 0;
        if (d.j)
            throw rb("ba").N;
        d.j = !0;
        if (null == e || null == d.B)
            d.H = d.D + (null != d.g ? (d.A.g ? performance.now() : Date.now()) - d.g : 0),
            d.g = null,
            null == e && (e = d.B),
            d.C && (e = d.C.g(d.o, e)),
            d.I.A.log(d.o, d.H, d.F, e, d.L),
            d.v && d.v.j(d.o, d.H, e);
        delete a.g[c]
    }
}
function uj(a, c) {
    c in a.g && delete a.g[c]
}
;pj.prototype.saveInitialLoadStats = pj.prototype.B;
pj.prototype.getInitialLoadStats = pj.prototype.C;
function sj() {
    this.j = this.L = this.F = !1;
    this.D = 0
}
y(sj, B);
sj.prototype.start = function() {
    if (this.j)
        throw rb("da").N;
    if (null != this.g)
        throw rb("ea").N;
    this.g = this.A.g ? performance.now() : Date.now();
    this.v && this.v.g(this.o)
}
;
function vj() {
    this.g = !1
}
var wj;
y(vj, B);
function qj() {
    xj();
    return wj
}
function yj() {
    var a = new vj;
    a.g = "performance"in z && !!performance.now;
    return a
}
function xj() {
    xj = n();
    wj = yj()
}
;function zj(a) {
    pj.call(this, a)
}
y(zj, pj);
var Aj;
function Bj() {
    var a;
    if (!Aj) {
        var c = new Cj(null);
        Aj = function() {
            return c
        }
    }
    return a = Aj,
    a()
}
;function Dj() {}
y(Dj, B);
Dj.prototype.get = function() {
    if (!this.j) {
        var a = z._docs_flag_initialData;
        this.j = a ? a : {}
    }
    return this.j
}
;
Dj.prototype.g = function() {
    return this.get()
}
;
function Cj(a) {
    this.g = new Dj;
    if (a)
        for (var c in a) {
            var d = c
              , e = a[c];
            Wi(this.g.g(), d, e)
        }
}
y(Cj, B);
Cj.prototype.clear = function() {
    this.g = new Dj
}
;
Cj.prototype.get = function(a) {
    return this.g.g()[a]
}
;
function Ej(a, c) {
    a = a.g.g();
    return c in a
}
function S(a, c) {
    a = a.get(c);
    return "string" == typeof a ? "true" == a || "1" == a : !!a
}
function Fj(a, c) {
    if (!Ej(a, c) || null == a.get(c))
        return NaN;
    try {
        var d = C(a.get(c));
        nb || (nb = RegExp("^\\s*[+-]?(NaN|Infinity|((\\d+\\.?\\d*)|(\\.\\d+))([eE][+-]?\\d+)?[dDfF]?)\\s*$"));
        if (!nb.test(d)) {
            var e = new $b;
            Va(e, "q`" + C(d));
            Xa(e, Error(e));
            throw e.N;
        }
        return parseFloat(d)
    } catch (g) {
        var f = Za(g);
        if (f instanceof $b)
            return NaN;
        throw f.N;
    }
}
function T(a, c) {
    if (!Ej(a, c))
        return "";
    a = a.get(c);
    var d;
    null == a ? d = "" : "number" === typeof a && Kb(a) == Kb(a) ? d = "" + Kb(a) : d = C(a);
    return d
}
function Gj(a) {
    var c = a.get("docs-sw-rpl");
    if (!Ej(a, "docs-sw-rpl") || null == c)
        return [];
    if (!Array.isArray(c))
        throw Pb("fa`docs-sw-rpl").N;
    for (var d = [], e = 0; e < c.length; e = e + 1 | 0) {
        var f = c[e];
        d.push("object" === Si(f) ? "[object Object]" : C(f))
    }
    Wi(a.g.g(), "docs-sw-rpl", d);
    return d
}
;function Hj(a) {
    this.g = {};
    a || qj()
}
var Ij = {
    cov: "mark_fully_visible",
    coe: "mark_interactive",
    fcoe: "mark_fully_loaded"
};
y(Hj, B);
Hj.prototype.j = function(a) {
    Jj(this, a, Date.now());
    this.o && (this.o.g(a),
    a = Ij[a],
    null != a && this.o.g(a))
}
;
Hj.prototype.v = function(a, c) {
    a in this.g || Ti(this.g, a, 0);
    Ti(this.g, a, this.g[a] + c)
}
;
function Jj(a, c, d) {
    if (c in a.g)
        throw D("ha`" + C(c)).N;
    Ti(a.g, c, d)
}
Hj.prototype.A = function(a) {
    if (!S(Bj(), "icso")) {
        if (a)
            for (var c in a)
                Jj(this, c, a[c]);
        Jj(this, "sldummy", 0)
    }
}
;
Hj.prototype.setTime = Hj.prototype.j;
Hj.prototype.incrementTime = Hj.prototype.v;
Hj.prototype.setServerValues = Hj.prototype.A;
var Kj;
function Lj() {
    Lj = n();
    Kj = new Hj(null)
}
;function Mj() {}
y(Mj, B);
function Nj() {
    return Lj(),
    Kj
}
z._getTimingInstance = Nj;
z._docsTiming = Mj;
function Oj() {
    this.g = !1
}
y(Oj, Vh);
function Pj() {}
y(Pj, B);
Pj.prototype.na = function(a) {
    return Qj(this, a)
}
;
Pj.prototype.La = function() {
    for (var a = 1, c = Rj(this), d = 0; d < c.length; d++) {
        var e = this[c[d]];
        null != e && (e = e.xb ? Yb(e) : Zb(e),
        a = Math.imul(1000003, a) ^ e)
    }
    return a
}
;
Pj.prototype.toString = function() {
    var a = cc(this);
    a = C(Na(a.g)) + C(gb("[]", a.j));
    a = a.substr(a.lastIndexOf(".") + 1 | 0);
    a = a.substr(a.lastIndexOf("$") + 1 | 0);
    a = a.substr(a.lastIndexOf("AutoValue_") + 1 | 0);
    var c = C(a) + "{";
    a = new Vb;
    a.v = ", ".toString();
    a.o = c.toString();
    a.j = "}".toString();
    a.A = C(a.o) + C(a.j);
    c = Rj(this);
    for (var d = 0; d < c.length; d++) {
        var e = c[d]
          , f = this[e];
        Array.isArray(f) && (f = "[" + C(f) + "]");
        var g = a;
        e = C(e) + "=" + C(f);
        g.g ? Ub(g.g, g.v) : (f = new Tb,
        f.g = g.o,
        g.g = f);
        g = g.g;
        g.g = C(g.g) + C(e)
    }
    return a.toString()
}
;
function Qj(a, c) {
    if (null == c || !isObject(cc(c), cc(a)))
        return !1;
    var d = Rj(a);
    if (d.length != Rj(c).length)
        return !1;
    for (var e = 0; e < d.length; e++) {
        var f = d[e]
          , g = a[f];
        f = c[f];
        if (!(isObject(g, f) || (null == g || null == f ? 0 : g.xb && f.xb ? isObject(cc(g), cc(f)) && Wb(g, f) : Xb(g, f))))
            return !1
    }
    return !0
}
function Rj(a) {
    var c = Object.keys(a)
      , d = a.B;
    return d ? c.filter(function(e) {
        return !d.includes(e)
    }) : c
}
;function Sj() {
    this.g = !1;
    this.o = {};
    this.j = null
}
y(Sj, Oj);
Sj.prototype.K = function() {
    Oj.prototype.K.call(this);
    var a = this.o, c;
    for (c in a)
        delete a[c];
    this.j = null
}
;
Sj.prototype.dispatchEvent = function(a) {
    if (!this.j) {
        var c = this.o;
        var d = [], e;
        for (e in c)
            d.push(c[e]);
        this.j = d
    }
    c = this.j;
    for (d = 0; d < c.length; d = d + 1 | 0)
        (0,
        c[d])(a)
}
;
function Tj() {}
y(Tj, B);
function Uj() {
    this.g = !1;
    this.j = []
}
y(Uj, Vh);
function Vj(a, c, d) {
    var e;
    a: {
        for (e = 0; e < a.j.length; e = e + 1 | 0) {
            var f = a.j[e];
            if (isObject(f.j, d) && isObject(f.g, c)) {
                e = !0;
                break a
            }
        }
        e = !1
    }
    if (!e) {
        a = a.j;
        if (null == d)
            throw $a().N;
        e = c.o;
        if (ei(d)in e) {
            c = [d];
            for (d = 0; d < c.length; d = d + 1 | 0) {
                a = c;
                e = d;
                f = c[d];
                if (null == f)
                    var g = "null";
                else
                    try {
                        g = f.toString()
                    } catch (l) {
                        if (g = Za(l),
                        g instanceof bb)
                            f = C(Ra(cc(f))) + String.fromCharCode(64) + C(Ta(ac(f))),
                            g = "<" + C(f) + " threw " + C(Ra(cc(g))) + ">";
                        else
                            throw g.N;
                    }
                a[e] = g
            }
            g = new Tb;
            g.g = "";
            for (d = f = 0; d < c.length; ) {
                a = void 0;
                e = "Observer %s previously registered.".indexOf("%s", f);
                if (-1 == e)
                    break;
                g.g = C(g.g) + C("Observer %s previously registered.".substr(f, e - f | 0));
                f = g;
                var h = c[a = d,
                d = d + 1 | 0,
                a];
                f.g = C(f.g) + C(h);
                f = e + 2 | 0
            }
            g.g = C(g.g) + C("Observer %s previously registered.".substr(f, 34 - f | 0));
            if (d < c.length) {
                var k;
                Ub(g, " [");
                a = c[k = d,
                d = d + 1 | 0,
                k];
                for (g.g = C(g.g) + C(a); d < c.length; )
                    k = void 0,
                    Ub(g, ", "),
                    a = g,
                    e = c[k = d,
                    d = d + 1 | 0,
                    k],
                    a.g = C(a.g) + C(e);
                g.g = C(g.g) + String.fromCharCode(93)
            }
            throw rb(g.toString()).N;
        }
        Ti(c.o, ei(d), d);
        c.j = null;
        k = new Tj;
        k.g = c;
        k.j = d;
        a.push(k)
    }
}
Uj.prototype.K = function() {
    var a;
    for (a = this.j.pop(); a; ) {
        var c = a.g;
        a = a.j;
        var d = c.o;
        ei(a)in d && (d = c.o,
        a = ei(a),
        delete d[a],
        c.j = null);
        a = this.j.pop()
    }
    Vh.prototype.K.call(this)
}
;
function U() {
    this.g = !1
}
y(U, Vh);
v = U.prototype;
v.qc = function(a) {
    if (!(0 <= di(this.ba(), a.A)))
        throw D("ka`" + C(a.A)).N;
    return this.hb(a)
}
;
v.va = function(a, c) {
    var d = this.ka(a)
      , e = [];
    a = new Wj(d,a,c,null);
    e.push(a);
    return e
}
;
v.hb = function(a) {
    return this.va(a, null)
}
;
v.ka = function(a) {
    throw D("la`" + C(a.A)).N;
}
;
v.aa = function(a) {
    return Xj(a) ? 0 <= di(this.ba(), a.o) : !1
}
;
function Yj(a) {
    this.g = a
}
y(Yj, B);
Yj.prototype.getType = q("g");
function Xj(a) {
    a = a.getType();
    return "update-record" === a || "delete-record" === a
}
;function Zj(a, c, d) {
    this.g = a;
    this.A = c;
    this.o = d
}
y(Zj, Yj);
function V(a) {
    if (null == a.A)
        throw D("ma").N;
    return a.A
}
;function ak(a, c) {
    this.g = a;
    this.j = c
}
y(ak, B);
function bk(a) {
    for (var c in a) {
        if (!a.hasOwnProperty(c) || "function" === typeof c)
            return !1;
        var d = a[c];
        if (Ca(d) && !Array.isArray(d))
            return bk(d);
        if (Array.isArray(d))
            return ck(d)
    }
    return !0
}
function ck(a) {
    for (var c = 0; c < a.length; c++) {
        if (Ca(a[c]) && !Array.isArray(a[c]))
            return bk(a[c]);
        if (Array.isArray(a[c]))
            return ck(a[c])
    }
    return !0
}
;function dk(a, c, d) {
    this.A = a;
    this.g = {};
    this.v = {};
    this.D = !0 === d;
    this.o = !this.D;
    this.L = c
}
y(dk, B);
dk.prototype.Sa = function() {
    return this.D || !Ui(this.v)
}
;
function ek(a, c) {
    a = fk(a, c);
    return null == a ? null : a instanceof Array ? a.concat() : Vi(a)
}
function gk(a, c) {
    a = hk(a, c);
    return null == a || 0 == a ? null : a
}
function hk(a, c) {
    a = fk(a, c);
    return null == a ? null : a
}
function ik(a, c) {
    a = fk(a, c);
    return null == a ? null : a
}
function jk(a, c) {
    return null == fk(a, c) ? null : 0 != a.g[c].length
}
function W(a, c, d) {
    X(a, c, d ? "true" : "")
}
function kk(a, c) {
    a = fk(a, c);
    return null == a ? null : a.concat()
}
function fk(a, c) {
    a = a.g[c];
    return null != a ? a : null
}
function X(a, c, d) {
    if (d instanceof Array)
        S(a.L, "docs-anlpfdo") || lk(d, [], S(a.L, "docs-anlpfdo")),
        mk(d, [], S(a.L, "docs-anlpfdo")),
        ck(d),
        null != a.g[c] && aj(a.g[c], d) || (d = d.concat(),
        a.g[c] = d ? d : null,
        a.o || (a.v[c] = d ? d : null));
    else if (Sb(d) || "string" === typeof d || "number" === typeof d || "boolean" === typeof d ? 0 : "object" === Si(d))
        mk(d, [], S(a.L, "docs-anlpfdo")),
        bk(d),
        null != a.g[c] && cj(a.g[c], d) || (d = Vi(d),
        a.g[c] = d ? d : null,
        a.o || (a.v[c] = d ? d : null));
    else {
        var e = a.g[c];
        (null == e ? null == d : Sb(d) ? Xb(e, d.g) : Xb(e, d)) || (Wi(a.g, c, d),
        a.o || Wi(a.v, c, d))
    }
}
function nk(a, c, d) {
    X(a, c, d)
}
function ok(a, c, d, e) {
    pk(a.g, c, d, e);
    a.o || pk(a.v, c, d, e)
}
function qk(a, c, d) {
    return (a = fk(a, c)) ? d in a ? a[d] : null : null
}
function pk(a, c, d, e) {
    var f = Xi(a, c);
    if (!f) {
        var g = f = {};
        a[c] = g ? g : null
    }
    null == e ? f[d] = null : Wi(f, d, e)
}
dk.prototype.sb = function() {
    this.v = {};
    this.D = !1
}
;
dk.prototype.Eb = aa(null);
function lk(a, c, d) {
    c.push(a);
    for (var e = 0; e < a.length; e = e + 1 | 0)
        if (Array.isArray(a[e])) {
            if (d)
                di(c, a[e]);
            else if (0 <= di(c, a[e]))
                throw D("oa").N;
            lk(a[e], c, d)
        }
    c.pop()
}
;function mk(a, c, d) {
    c.push(a);
    if (a instanceof Array)
        for (var e = 0; e < a.length; e++) {
            var f = a[e];
            if (null != f) {
                if (d)
                    di(c, f);
                else if (0 <= di(c, f))
                    throw D("oa").N;
                mk(f, c, d)
            }
        }
    else if (a instanceof Object)
        for (e = Object.keys(a),
        f = 0; f < e.length; f++) {
            var g = e[f];
            if (null != a[g]) {
                if (d)
                    di(c, a[g]);
                else if (0 <= di(c, a[g]))
                    throw D("oa").N;
                mk(a[g], c, d)
            }
        }
    c.pop()
}
;function Wj(a, c, d, e) {
    Zj.call(this, e ? e : "update-record", a, c.A);
    a = d;
    this.ja = c.D;
    this.Y = {};
    d = c.v;
    a = a ? a : [];
    for (var f in d)
        Wi(this.Y, f, 0 <= di(a, f) ? fk(c, f) : c.g[f])
}
y(Wj, Zj);
function rk(a) {
    var c = new Zi;
    a = sk.indexOf(a);
    var d = a >= sk.indexOf(5)
      , e = a >= sk.indexOf(4)
      , f = a >= sk.indexOf(2)
      , g = a >= sk.indexOf(3);
    J(c, 1, a >= sk.indexOf(1));
    J(c, 2, d);
    J(c, 3, e);
    J(c, 4, f);
    J(c, 8, f);
    J(c, 5, g);
    J(c, 7, g);
    J(c, 6, g);
    J(c, 9, f);
    J(c, 10, f);
    J(c, 11, f);
    J(c, 12, f);
    J(c, 13, f);
    J(c, 14, g);
    J(c, 15, g);
    J(c, 17, g);
    J(c, 18, e);
    J(c, 20, g);
    J(c, 16, !1);
    J(c, 19, !1);
    J(c, 21, g);
    J(c, 22, g);
    J(c, 23, f);
    J(c, 24, !1);
    return c
}
;function tk(a, c) {
    uk();
    this.g = c
}
var vk;
y(tk, B);
tk.prototype.bc = function(a, c) {
    for (var d = xb(vk.g()), e = [], f = 0; f < a.length; f = f + 1 | 0)
        e.push(new wk(a[f]));
    !0 === c && (a = xb(vk.g()) - d,
    this.g.v("md", a));
    return e
}
;
function uk() {
    uk = n();
    vk = new xk
}
;function xk() {}
y(xk, B);
xk.prototype.g = function() {
    return Ib(Date.now())
}
;
function yk(a) {
    this.j = a
}
y(yk, B);
yk.prototype.g = function() {
    var a;
    return a = this.j,
    a()
}
;
function zk() {
    this.j = !1;
    this.g = []
}
y(zk, B);
function Ak(a, c, d) {
    !0 === d && (a.g = [],
    a.j = !0);
    a.g.push(c)
}
function Bk(a) {
    var c = a.g;
    a.g = [];
    a.j = !1;
    return c
}
;function Ck(a, c, d, e, f, g) {
    this.g = 0;
    this.v = a;
    this.A = d;
    this.j = e;
    this.o = f;
    this.g = g ? g.g : 0
}
y(Ck, B);
function Dk(a, c, d, e) {
    dk.call(this, "document", e, d);
    this.j = new zk;
    this.C = new Ek;
    X(this, "id", a);
    X(this, "documentType", c)
}
var sk = [0, 1, 5, 4, 2, 3];
y(Dk, dk);
v = Dk.prototype;
v.R = function() {
    return this.g.id
}
;
v.getType = function() {
    return this.g.documentType
}
;
function Fk(a, c) {
    X(a, "jobset", c)
}
v.sa = function() {
    return ik(this, "jobset")
}
;
function Gk(a, c, d) {
    X(a, "rev", c);
    c = a.C.Z(d);
    X(a, "rai", c)
}
function Hk(a, c, d) {
    d = d.Z();
    ok(a, "acjf", c, d)
}
function Ik(a, c) {
    X(a, "lastModifiedClientTimestamp", c)
}
v.Eb = function() {
    var a = 0 == this.j.g.length;
    return a ? dk.prototype.Eb.call(this) : new ak(this.R(),a ? 1 : 2)
}
;
function Jk(a) {
    var c = a.getType()
      , d = a.sa();
    return new Kk(c,d,null == fk(a, "isFastTrack") ? !1 : 0 != a.g.isFastTrack.length)
}
function Lk(a, c) {
    X(a, "ic", c)
}
v.Sa = function() {
    return dk.prototype.Sa.call(this) || 0 != this.j.g.length
}
;
function Mk(a, c, d) {
    this.g = a;
    this.j = c;
    this.v = d
}
y(Mk, Yj);
function Nk(a, c, d, e) {
    Mk.call(this, "append-commands", a, c);
    this.o = d;
    this.A = e
}
y(Nk, Mk);
function Ok(a, c, d) {
    this.g = !1;
    this.Rc = a;
    this.Db = c;
    this.Pc = new tk(this.Db,d)
}
y(Ok, Vh);
Ok.prototype.Ja = q("Rc");
Ok.prototype.bc = function(a, c) {
    return this.Pc.bc(a, c)
}
;
Ok.prototype.Ub = function(a) {
    var c = new zk
      , d = a.j
      , e = d.g;
    for (var f = 0; f < e.length; f++)
        Ak(c, e[f], d.j),
        d.j = !1;
    d.g = [];
    if (0 == c.g.length)
        return [];
    d = c.j;
    return [new Nk(a.R(),a.getType(),Bk(c),d)]
}
;
function Pk(a, c) {
    Rh.call(this, a, c);
    Xa(this, Error(this))
}
y(Pk, Rh);
function Qk(a, c, d) {
    Pk.call(this, "Local storage error: " + C(c), null);
    this.type = 0;
    this.type = a;
    this.cause = d;
    Xa(this, Error(this))
}
y(Qk, Pk);
function Rk(a, c) {
    a = new Qk(a,c,null,null);
    Xa(a, Error(a));
    return a
}
;function Kk(a, c, d) {
    this.o = a;
    this.j = c;
    this.g = d
}
y(Kk, B);
Kk.prototype.getType = q("o");
Kk.prototype.sa = q("j");
function Sk(a) {
    this.g = a
}
y(Sk, B);
function Ek() {}
y(Ek, B);
Ek.prototype.Z = function(a) {
    return a ? [a.g] : null
}
;
function Tk(a, c, d, e) {
    this.g = "append-template-commands";
    this.j = a;
    this.v = c;
    this.o = d;
    this.A = e
}
y(Tk, Yj);
Tk.prototype.Ja = q("v");
function Uk(a, c, d) {
    dk.call(this, "applicationMetadata", d, c);
    this.j = !1;
    X(this, "dt", a);
    this.C = []
}
y(Uk, dk);
Uk.prototype.Ja = function() {
    return this.g.dt
}
;
Uk.prototype.sa = function() {
    return ik(this, "jobset")
}
;
function Vk(a) {
    a = hk(a, "version");
    null == a && (a = 0);
    return Kb(a)
}
Uk.prototype.sb = function() {
    dk.prototype.sb.call(this);
    this.j = !1
}
;
Uk.prototype.Sa = function() {
    return this.j || dk.prototype.Sa.call(this)
}
;
function Wk() {
    this.g = this.o = this.A = this.v = this.C = this.B = 0
}
y(Wk, B);
function Xk(a) {
    var c = new Wk;
    if (null == a)
        throw $a().N;
    c.j = a;
    return c
}
function Yk(a, c) {
    a.B = c;
    a.g = (a.g | 1) << 24 >> 24;
    return a
}
function Zk(a, c) {
    a.C = c;
    a.g = (a.g | 2) << 24 >> 24;
    return a
}
function $k(a, c) {
    a.v = c;
    a.g = (a.g | 4) << 24 >> 24;
    return a
}
function al(a, c) {
    a.A = c;
    a.g = (a.g | 8) << 24 >> 24;
    return a
}
function bl(a, c) {
    a.o = c;
    a.g = (a.g | 16) << 24 >> 24;
    return a
}
function cl(a) {
    if (31 != a.g || null == a.j)
        throw qb().N;
    var c = new dl
      , d = a.B
      , e = a.C
      , f = a.v
      , g = a.A
      , h = a.o;
    c.C = a.j;
    c.A = d;
    c.v = e;
    c.j = f;
    c.o = g;
    c.g = h;
    return c
}
;function dl() {
    this.g = this.o = this.j = this.v = this.A = 0
}
y(dl, Pj);
var fl = "c oc ol op ou ppu ppe u".split(" ");
function gl() {
    this.g = !1
}
y(gl, U);
v = gl.prototype;
v.ba = function() {
    return []
}
;
v.va = function() {
    throw D("ta").N;
}
;
v.hb = function(a) {
    return this.va(a, null)
}
;
v.ka = function() {
    throw D("ua").N;
}
;
v.aa = aa(!1);
function hl() {
    this.g = !1
}
y(hl, U);
hl.prototype.ba = function() {
    return ["comment"]
}
;
hl.prototype.ka = function(a) {
    return [a.g.di, a.R()]
}
;
function il(a, c) {
    this.g = !1;
    this.Yb = a;
    this.Sc = c
}
y(il, U);
v = il.prototype;
v.ba = function() {
    return ["document"]
}
;
v.Ia = function(a) {
    var c = this.Yb[a];
    if (!c)
        throw D("va`" + C(a)).N;
    return c
}
;
v.createDocument = function(a, c, d) {
    a = new Dk(a,c,!0,this.Sc,this.Yb[c]);
    null == d || null == hk(a, "initialSyncReason") && X(a, "initialSyncReason", d);
    return a
}
;
v.aa = function(a) {
    var c = a.getType();
    return "append-commands" === c || "write-trix" === c ? !0 : U.prototype.aa.call(this, a)
}
;
v.va = function(a) {
    var c = U.prototype.va.call(this, a, "approvalMetadataStatus contentLockType lastModifiedClientTimestamp lastWarmStartedTimestamp ic odocid relevancyRank rev rai snapshotProtocolNumber snapshotVersionNumber fileLockedReason mimeType resourceKey initialPinSourceApp quotaStatus".split(" "));
    a = this.Ia(a.getType()).Ub(a);
    return c.concat(a)
}
;
v.ka = function(a) {
    return a.R()
}
;
function jl(a, c) {
    this.g = !1;
    this.Qc = a;
    this.Ba = c
}
y(jl, U);
v = jl.prototype;
v.ba = function() {
    return ["applicationMetadata"]
}
;
v.ka = function(a) {
    return a.Ja()
}
;
v.aa = function(a) {
    return ic(a.getType(), "update-application-metadata")
}
;
v.va = function(a) {
    var c = this.ka(a);
    return [new kl(c,a,a.j ? a.C.slice(0) : null)]
}
;
v.Ia = function(a) {
    var c = this.Qc[a];
    if (!c)
        throw D("va`" + C(a)).N;
    return c
}
;
function kl(a, c, d) {
    Wj.call(this, a, c, null, "update-application-metadata");
    this.j = d
}
y(kl, Wj);
function ll() {
    this.g = !1
}
y(ll, U);
ll.prototype.ba = function() {
    return ["documentEntity"]
}
;
ll.prototype.ka = function(a) {
    return [a.g.documentId, a.getType(), a.R()]
}
;
function ml() {
    this.g = !1
}
y(ml, U);
ml.prototype.ba = function() {
    return []
}
;
function nl(a, c) {
    this.g = "document-lock";
    this.j = a;
    this.o = c
}
y(nl, Yj);
function ol(a, c) {
    if (S(c, "docs-offline-ercidep") && !S(c, "docs-localstore-cide"))
        return !1;
    switch (a) {
    case "kix":
    case "punch":
    case "drawing":
    case "ritz":
    case "test":
        return !S(c, "docs-localstore-dom");
    default:
        return !1
    }
}
;function pl(a, c, d, e, f, g) {
    dk.call(this, "impressionBatch", g, f);
    X(this, "di", a);
    X(this, "dt", c);
    X(this, "ibt", d);
    X(this, "iba", e)
}
y(pl, dk);
function ql() {
    this.g = !1
}
y(ql, U);
ql.prototype.ba = function() {
    return ["impressionBatch"]
}
;
ql.prototype.ka = function(a) {
    var c = [];
    c.push(ik(a, "di"));
    c.push.call(c, a.g.ibt);
    return c
}
;
ql.prototype.aa = function(a) {
    return U.prototype.aa.call(this, a) && (ic(a.getType(), "update-record") && a.ja || ic(a.getType(), "delete-record"))
}
;
function rl() {
    this.g = !1
}
y(rl, U);
rl.prototype.ba = function() {
    return []
}
;
function sl(a, c, d) {
    this.g = a;
    this.j = c;
    this.o = d
}
y(sl, B);
function tl(a) {
    this.g = a
}
y(tl, B);
function ul(a) {
    this.o = this.g = !1;
    this.j = a;
    this.v = new Sj
}
y(ul, Vh);
function vl(a) {
    if (a.o)
        throw D("xa").N;
    a.o = !0
}
ul.prototype.rb = function() {
    return this.j.rb()
}
;
ul.prototype.write = function(a, c, d) {
    var e = this;
    if (!this.o)
        throw D("ya").N;
    var f = wl(a);
    a = xl(this, a);
    0 == a.length ? c() : yl(this.j, a, function() {
        e.v.dispatchEvent(f);
        c()
    }, d)
}
;
function wl(a) {
    var c = [];
    for (var d = 0; d < a.length; d++) {
        var e = a[d];
        c.push(new sl(e,e.D ? "new" : "update",e.v))
    }
    return new tl(c,null)
}
function xl(a, c) {
    var d = []
      , e = null;
    for (var f = 0; f < c.length; f++) {
        var g = c[f];
        if (g.Sa()) {
            var h = a.j;
            var k = g.A;
            if (h = k in h.B ? h.B[k] : null) {
                h = h.qc(g);
                fi(d, h);
                if ((h = g.Eb()) && e) {
                    if (!isObject(e.g, h.g))
                        throw D("na").N;
                    e = e.j > h.j ? e : h
                } else
                    e = e ? e : h;
                g.sb()
            } else
                throw D("za`" + C(g.A)).N;
        }
    }
    e && d.unshift(new nl(e.g,e.j));
    return d
}
ul.prototype.toString = aa("[LocalStore]");
function zl() {
    this.g = !1
}
y(zl, U);
zl.prototype.ba = function() {
    return []
}
;
function Al() {
    this.g = !1
}
y(Al, U);
Al.prototype.ba = function() {
    return ["blobMetadata"]
}
;
Al.prototype.va = function(a) {
    return U.prototype.va.call(this, a, fl)
}
;
Al.prototype.hb = function(a) {
    return this.va(a, null)
}
;
Al.prototype.ka = function(a) {
    return [a.g.d, a.g.p]
}
;
function Bl(a, c, d, e, f, g, h) {
    dk.call(this, "pendingQueue", h, d);
    this.O = !1;
    this.B = 6;
    this.j = e;
    this.J = f.slice(0);
    this.M = g.slice(0);
    this.P = new Ek;
    X(this, "docId", a);
    X(this, "documentType", c);
    X(this, "revision", -1);
    W(this, "undeliverable", !1);
    W(this, "unsavedChanges", !1)
}
var Cl = ["revisionAccessInfo", "unsentBundleMetadata", "selection", "sentBundlesSavedRevision", "snapshotBundleIndex"];
y(Bl, dk);
function Dl(a) {
    return a.g.docId
}
function El(a) {
    var c = Rb(1);
    X(a, "revision", c);
    c = a.P.Z(null);
    X(a, "revisionAccessInfo", c)
}
v = Bl.prototype;
v.getType = function() {
    return this.g.documentType
}
;
function Fl(a, c) {
    X(a, "unsentBundleMetadata", c)
}
v.clear = function() {
    W(this, "undeliverable", !1);
    W(this, "unsavedChanges", !1);
    X(this, "sentBundlesSavedRevision", null);
    X(this, "selection", null);
    X(this, "snapshotBundleIndex", null);
    var a = this.J;
    for (var c = 0; c < a.length; c++) {
        var d = a[c].g();
        for (var e = 0; e < d.length; e++)
            d[e].X()
    }
    this.J = [];
    a = this.M;
    for (c = 0; c < a.length; c++)
        for (d = a[c].g(),
        e = 0; e < d.length; e++)
            d[e].X();
    this.M = [];
    if (6 != this.B)
        throw rb("Da`" + this.B + "`2").N;
    this.B = 2
}
;
v.Sa = function() {
    return 6 != this.B || dk.prototype.Sa.call(this)
}
;
v.sb = function() {
    dk.prototype.sb.call(this);
    this.I && 0 != this.I.length && (this.j = this.j + 1 | 0);
    this.F && (this.j = this.j + this.F.length | 0);
    this.H && (this.j = this.j + this.H.length | 0);
    this.B = 6;
    this.C = this.H = this.F = this.I = null
}
;
v.Eb = function() {
    return new ak(Dl(this),2)
}
;
v.X = function() {
    this.O = !0;
    var a = this.J;
    for (var c = 0; c < a.length; c++) {
        var d = a[c].g();
        for (var e = 0; e < d.length; e++) {
            var f = d[e];
            f && f.X()
        }
    }
    a = this.M;
    for (c = 0; c < a.length; c++)
        for (d = a[c].g(),
        e = 0; e < d.length; e++)
            (f = d[e]) && f.X()
}
;
v.wa = q("O");
function Gl(a, c, d) {
    this.g = a;
    this.j = c;
    this.o = d
}
y(Gl, B);
Gl.prototype.Z = function() {
    var a = {};
    a.rid = this.g;
    var c = this.j;
    a.sid = null != c ? c : null;
    a.lei = this.o;
    return a
}
;
function Hl(a, c, d) {
    this.j = a;
    this.g = c;
    this.o = d
}
y(Hl, B);
Hl.prototype.ba = function() {
    return ["pendingQueue"]
}
;
Hl.prototype.ka = function(a) {
    return Dl(a)
}
;
Hl.prototype.qc = function(a) {
    var c = a.getType();
    var d = this.j[c];
    if (!d)
        throw D("Ea`" + C(c)).N;
    var e = a.B;
    c = [];
    switch (e) {
    case 7:
        e = d;
        c = Dl(a);
        var f = a.j
          , g = a.F;
        d = [];
        for (var h = 0; h < g.length; h++) {
            var k = g[h];
            f = f + 1 | 0;
            k = Il(this, k.j(), e, Dl(a), f, !0);
            if (!k)
                throw D("Ia").N;
            d.push(k)
        }
        g = a.j + d.length | 0;
        h = a.H ? a.H : [];
        k = [];
        f = [];
        for (var l = 0; l < h.length; l++) {
            var m = h[l];
            var p = m.j();
            if (p = Il(this, p, e, c, g + 1 | 0, null))
                f.push(p),
                p = k,
                m = new Gl(m.o(),m.v(),g + 1 | 0),
                p.push(m),
                g = g + 1 | 0
        }
        Fl(a, Jl(k));
        e = new Kl(a);
        d.push(e);
        fi(d, f);
        0 <= a.j && d.push(new Ll(c,a.j));
        c = d;
        break;
    case 1:
        e = a.j + 1 | 0;
        f = Dl(a);
        c = [];
        g = a.I;
        h = a.C ? Rb(a.C.g) : null;
        k = a.C ? a.C.j : null;
        if (l = ek(a, "unsentBundleMetadata")) {
            m = [];
            for (p = 0; p < l.length; p = p + 1 | 0)
                m.push(new Gl(l[p].rid,l[p].sid,l[p].lei));
            l = m
        } else
            l = [];
        if (h && null != k)
            l.push(new Gl(h.g,k,e));
        else {
            if (0 == l.length)
                throw D("Ha").N;
            h = l[l.length - 1 | 0];
            l[l.length - 1 | 0] = new Gl(h.g,h.j,e)
        }
        g && Fl(a, Jl(l));
        Ui(a.v) || (a = new Wj(f,a,Cl,null),
        c.push(a));
        (a = Il(this, g, d, f, e, null)) && c.push(a);
        break;
    case 5:
        Fl(a, null);
        d = c;
        a = new Kl(a);
        d.push(a);
        break;
    case 2:
        Fl(a, null);
        d = c;
        a = new Ml(a);
        d.push(a);
        break;
    case 3:
        d = c;
        a = new Nl(a);
        d.push(a);
        break;
    case 4:
        d = c;
        a = new Ol(a);
        d.push(a);
        break;
    case 6:
        d = c;
        a = new Wj(Dl(a),a,Cl,null);
        d.push(a);
        break;
    default:
        throw D("Ga`" + e).N;
    }
    return c
}
;
function Il(a, c, d, e, f, g) {
    if (!(!0 === g || c && 0 != c.length))
        return null;
    g = [];
    if (c) {
        var h = [];
        for (var k = 0; k < c.length; k++) {
            var l = d.Db.Z(c[k]);
            g.push(l);
            var m = h;
            l = Pl(JSON.stringify(l));
            fi(m, l)
        }
        0 < h.length && (c = {},
        d = "{" + C(h.join("; ")) + "}",
        c.command_malformedCharacterContext = null != d ? d : null,
        a = a.g,
        d = new bb,
        Va(d, "Serializing commands containing malformed surrogate characters."),
        Xa(d, Error(d)),
        a.info(d, c, null))
    }
    return new Ql(e,g,f)
}
function Jl(a) {
    if (0 == a.length)
        return null;
    var c = [];
    for (var d = 0; d < a.length; d++)
        c.push(a[d].Z());
    return c
}
;function Ml(a) {
    Wj.call(this, Dl(a), a, Cl, "pq-clear")
}
y(Ml, Wj);
function Ol(a) {
    Wj.call(this, Dl(a), a, Cl, "pq-clear-sent-bundle")
}
y(Ol, Wj);
function Nl(a) {
    Wj.call(this, Dl(a), a, Cl, "pq-clear-sent")
}
y(Nl, Wj);
function Ll(a, c) {
    this.g = "pq-delete-commands";
    this.j = a;
    this.o = c
}
y(Ll, Yj);
function Rl(a, c, d) {
    this.o = a;
    this.j = c;
    this.g = d
}
y(Rl, B);
function Kl(a) {
    Wj.call(this, Dl(a), a, Cl, "pq-mark-sent");
    this.v = !1;
    this.j = [];
    var c = a.j;
    if (7 == a.B) {
        this.v = !0;
        var d = a.F;
        for (var e = 0; e < d.length; e++) {
            var f = d[e];
            c = c + 1 | 0;
            a = this.j;
            var g = f.v();
            f = new Rl(g,f.o(),c);
            a.push(f)
        }
    } else
        this.v = !1,
        d = this.j,
        e = a.C ? a.C.j : null,
        a = a.C ? Rb(a.C.g) : null,
        d.push(new Rl(e,a.g,c))
}
y(Kl, Wj);
function Ql(a, c, d) {
    this.g = "pq-write-commands";
    this.v = a;
    this.o = c;
    this.j = d
}
y(Ql, Yj);
function Sl(a, c, d, e, f) {
    this.A = a;
    this.o = c;
    this.v = d;
    this.j = e;
    this.g = f
}
y(Sl, B);
Sl.prototype.toString = function() {
    var a = "MalformedCharacterContext(unicodeChar: " + C(this.A) + ", index: " + this.o + ", textLength: " + this.v;
    null != this.j && (a = C(a) + (", prev: " + C(this.j)));
    null != this.g && (a = C(a) + (", next: " + C(this.g)));
    return C(a) + ")"
}
;
Sl.prototype.na = function(a) {
    return a instanceof Sl && isObject(this.toString(), a.toString())
}
;
Sl.prototype.La = function() {
    return Yb([this.A, Rb(this.o), Rb(this.v), this.j, this.g])
}
;
function Pl(a) {
    for (var c = [], d = 0; d < a.length; d = d + 1 | 0) {
        var e = hc(a, d)
          , f = !1
          , g = a.charCodeAt(d)
          , h = Lb(a.charCodeAt(d));
        55296 <= g && 56319 >= g ? f = !(65536 <= e && 1114111 >= e) : h && (0 < d ? (f = hc(a, d - 1 | 0),
        f = !(65536 <= f && 1114111 >= f)) : f = !0);
        f && (e = "\\u" + C(Ta(e)),
        f = Tl(a, d - 1 | 0),
        g = Tl(a, d + 1 | 0),
        c.push(new Sl(e,d,a.length,f,g)))
    }
    return c
}
function Tl(a, c) {
    return 0 > c || c >= a.length ? null : "\\u" + C(Ta(hc(a, c)))
}
;function Ul(a) {
    this.newVersion = 0;
    this.newVersion = a
}
y(Ul, B);
function Vl() {
    this.g = !1;
    this.W = new Sj;
    this.B = {}
}
y(Vl, Vh);
function Wl(a, c) {
    var d = c.ba();
    for (var e = 0; e < d.length; e++) {
        var f = d[e];
        if (a.B[f])
            throw D("Ja`" + C(f)).N;
        Ti(a.B, f, c)
    }
}
Vl.prototype.fc = aa(null);
Vl.prototype.Xa = aa(null);
Vl.prototype.hc = aa(null);
Vl.prototype.ec = aa(null);
function Xl(a, c, d) {
    this.o = a;
    this.g = c;
    this.j = d
}
y(Xl, B);
function Yl(a, c, d, e) {
    dk.call(this, a, e, d);
    X(this, "dataType", c)
}
y(Yl, dk);
function Zl(a, c) {
    this.g = a;
    this.j = c
}
y(Zl, B);
Zl.prototype.Z = function() {
    var a = {}
      , c = this.g;
    a.docId = null != c ? c : null;
    c = this.j;
    a.resourceKey = null != c ? c : null;
    return a
}
;
function $l(a) {
    return new Zl(a.docId,a.resourceKey)
}
;function am(a, c, d) {
    Yl.call(this, "syncHints", ["synchints", "" + c], a, d);
    X(this, "docIds", []);
    a = Rb(c);
    X(this, "sourceApp", a);
    X(this, "docIdentifiers", [])
}
y(am, Yl);
function bm(a, c) {
    for (var d = [], e = 0; e < c.length; e = e + 1 | 0)
        d.push(c[e].Z());
    X(a, "docIdentifiers", d);
    X(a, "docIds", [])
}
function cm(a, c) {
    var d = [];
    for (var e = 0; e < c.length; e++) {
        var f = d
          , g = c[e];
        Sb(g) ? f.push(g.g) : f.push(g)
    }
    X(a, "docIds", d);
    X(a, "docIdentifiers", [])
}
function dm(a) {
    a = hk(a, "sourceApp");
    return null == a ? 0 : Kb(a)
}
;function em() {
    this.g = !1
}
y(em, U);
em.prototype.ba = function() {
    return ["syncHints"]
}
;
function fm(a, c) {
    var d = new Xh;
    gm(a, function(e) {
        Yh(d, e)
    }, function(e) {
        ai(d, e)
    });
    return ci(d, function(e) {
        var f = [];
        for (var g = 0; g < e.length; g++) {
            var h = e[g];
            var k = dm(h);
            var l = [], m;
            if (m = kk(h, "docIdentifiers")) {
                for (var p = [], r = 0; r < m.length; r = r + 1 | 0)
                    p.push($l(m[r]));
                m = p
            } else
                m = [];
            if (0 == m.length)
                for (h = (h = kk(h, "docIds")) ? dj(h) : [],
                m = 0; m < h.length; m = m + 1 | 0)
                    l.push(new Xl(k,h[m],m,null));
            else
                for (h = 0; h < m.length; h = h + 1 | 0)
                    p = m[h],
                    l.push(new Xl(k,p.g,h,p.j));
            k = l;
            for (l = 0; l < k.length; l++)
                if (h = k[l],
                isObject(c, h.g)) {
                    f.push(h);
                    break
                }
        }
        return Yi(f)
    })
}
em.prototype.ka = function(a) {
    return ["synchints", "" + dm(a)]
}
;
em.prototype.aa = function(a) {
    return U.prototype.aa.call(this, a) && ic(a.getType(), "update-record")
}
;
function hm() {
    this.g = !1
}
y(hm, U);
hm.prototype.ba = function() {
    return ["syncObject"]
}
;
hm.prototype.ka = function(a) {
    return dj(a.g.keyPath.concat())
}
;
hm.prototype.aa = function(a) {
    return U.prototype.aa.call(this, a) && ic(a.getType(), "update-record") && a.ja
}
;
function im(a, c) {
    Yl.call(this, "syncStats", "syncstats", a, c);
    X(this, "syncVersion", 0);
    X(this, "lastDailyRunTime", 0);
    X(this, "maxSpaceQuota", 0);
    X(this, "webfontsSyncVersion", 0);
    X(this, "lastStartedSyncDocs", []);
    X(this, "backgroundSyncDenylist", {})
}
y(im, Yl);
function jm(a, c, d) {
    var e = {};
    e.documentId = null != c ? c : null;
    e.timestamp = d;
    c = (c = kk(a, "lastStartedSyncDocs")) ? c : [];
    c.push(e);
    e = c.length - 10 | 0;
    0 < e && c.splice(0, e);
    X(a, "lastStartedSyncDocs", c)
}
function km(a, c) {
    var d = (d = ek(a, "backgroundSyncDenylist")) ? d : {};
    var e = c.C
      , f = {};
    f.retryCount = c.A;
    f.nextSyncTimestampMillis = c.v;
    f.firstFailTimestampMillis = c.j;
    f.lastFailTimestampMillis = c.o;
    f.documentDiskSize = c.g;
    d[e] = f ? f : null;
    X(a, "backgroundSyncDenylist", d)
}
function lm(a, c, d, e, f, g, h, k) {
    var l = {};
    l.count = d;
    l.modelSyncFailCount = e;
    l.serverTime = f;
    l.lastSyncErrorType = g ? g.g : null;
    l.nextSyncTimestampMillis = h;
    l.backoffRetryConsecutiveFailCount = k;
    d = mm(a);
    d[c] = l ? l : null;
    X(a, "failedToSyncDocs", d)
}
function mm(a) {
    return (a = ek(a, "failedToSyncDocs")) ? a : {}
}
;function nm(a) {
    this.g = !1;
    this.Ba = a
}
y(nm, U);
nm.prototype.ba = function() {
    return ["syncStats"]
}
;
function om(a, c) {
    var d = new Xh;
    pm(a, function(e) {
        Yh(d, e)
    }, function(e) {
        ai(d, e)
    });
    return ci(d, function(e) {
        e ? e = (e = Xi(mm(e), c)) && null != e.lastSyncErrorType ? Rb(e.lastSyncErrorType) : null : e = null;
        return Yi(e)
    })
}
nm.prototype.ka = aa(null);
nm.prototype.aa = function(a) {
    return U.prototype.aa.call(this, a) && !ic(a.getType(), "delete-record")
}
;
function qm(a, c) {
    this.g = !1;
    this.j = a;
    this.o = c
}
y(qm, Vh);
qm.prototype.Ub = function(a) {
    var c = Bk(a.j);
    return 0 == c.length ? [] : [new Tk(a.R(),a.Ja(),c,!0)]
}
;
qm.prototype.Ja = q("j");
function rm(a, c) {
    this.g = !1;
    this.Tc = a;
    this.Ba = c
}
y(rm, U);
v = rm.prototype;
v.ba = function() {
    return ["templateCreationMetadata", "templateMetadata"]
}
;
v.ka = function(a) {
    return "templateCreationMetadata" === a.A ? [a.R()] : [a.R()]
}
;
v.hb = function(a) {
    var c = U.prototype.hb.call(this, a);
    "templateCreationMetadata" === a.A && (a = this.Ia(a.Ja()).Ub(a),
    fi(c, a));
    return c
}
;
v.Ia = function(a) {
    var c = this.Tc[a];
    if (!c)
        throw D("va`" + C(a)).N;
    return c
}
;
v.aa = function(a) {
    return "append-template-commands" === a.getType() ? !0 : U.prototype.aa.call(this, a)
}
;
function sm(a, c, d) {
    dk.call(this, "user", d, c);
    X(this, "id", a);
    W(this, "fastTrack", !0)
}
y(sm, dk);
sm.prototype.R = function() {
    return this.g.id
}
;
function tm(a) {
    return 0 != a.g.fastTrack.length
}
;function um(a) {
    this.g = !1;
    this.Ba = a
}
y(um, U);
v = um.prototype;
v.ba = function() {
    return ["user"]
}
;
v.va = function(a, c) {
    return U.prototype.va.call(this, a, c)
}
;
v.hb = function(a) {
    return this.va(a, null)
}
;
v.ka = function(a) {
    return a.R()
}
;
v.aa = function(a) {
    return U.prototype.aa.call(this, a) && !ic(a.getType(), "delete-record")
}
;
function vm() {
    this.g = !1
}
y(vm, U);
vm.prototype.ba = function() {
    return ["fontMetadata"]
}
;
vm.prototype.fontFamily = function(a) {
    return a.g.fontFamily
}
;
vm.prototype.updateRecord = function(a) {
    return U.prototype.aa.call(this, a) ? ic(a.getType(), "update-record") ? a.ja : !0 : !1
}
;
function wm(a) {
    Rh.call(this, a, null);
    Xa(this, Error(this))
}
y(wm, Rh);
function xm() {}
var ym, zm, Am, Bm, Cm;
y(xm, B);
function Dm() {
    Dm = n();
    ym = new xm;
    zm = new xm;
    Am = new xm;
    Bm = new xm;
    Cm = new xm
}
;function Em(a, c, d, e) {
    this.g = !1;
    this.v = a;
    this.o = c;
    this.j = new Fm(Math.imul(d, 1E3),e)
}
y(Em, Vh);
function Gm(a) {
    return (a.j.get(null) + 1 | 0) / (a.j.o / 1E3) <= a.o
}
function Hm(a) {
    if (!Gm(a))
        throw (new wm("Query would cause " + C(a.v) + " to exceed " + a.o + " qps.")).N;
    a = a.j;
    var c = xb(a.v.g());
    Im(a, c);
    var d = Jm(a.j);
    if (!d || c >= d.j)
        d = new Km,
        d.j = a.g * Math.floor(c / a.g + 1),
        d.g = 0,
        d.v = 2147483647,
        d.o = -2147483648,
        a.j.add(d);
    d.g = d.g + 1 | 0;
    d.v = Math.min(1, d.v);
    d.o = Math.max(1, d.o)
}
;function Km() {
    this.o = this.v = this.g = 0
}
y(Km, B);
function Fm(a, c) {
    this.g = this.o = 0;
    this.v = c ? c : new xk;
    this.o = a;
    this.g = a / 50 | 0;
    this.j = new Lm(Rb(50))
}
y(Fm, B);
Fm.prototype.get = function(a) {
    return Mm(this, a, function(c, d) {
        return Rb(c.g + d.g | 0)
    })
}
;
function Mm(a, c, d) {
    c = null != c ? c : xb(a.v.g());
    Im(a, c);
    var e = 0;
    c = a.g * Math.floor(c / a.g + 1) - a.o;
    for (var f = a.j.g.length - 1 | 0; 0 <= f; f = f - 1 | 0) {
        var g = a.j.get(f);
        if (g.j <= c)
            break;
        e = d(Rb(e), g).g
    }
    return e
}
function Im(a, c) {
    var d;
    (d = Jm(a.j)) && c < d.j - a.g && a.j.clear()
}
;function Lm(a) {
    this.j = this.o = 0;
    var c;
    null != a ? c = "number" === typeof a ? Kb(a) : a.g : c = 100;
    this.o = c;
    this.g = []
}
y(Lm, B);
v = Lm.prototype;
v.add = function(a) {
    var c = this.g[this.j];
    this.g[this.j] = a;
    this.j = (this.j + 1 | 0) % this.o | 0;
    return c
}
;
v.get = function(a) {
    a = Nm(this, a);
    return this.g[a]
}
;
v.set = function(a, c) {
    a = Nm(this, a);
    this.g[a] = c
}
;
v.clear = function() {
    this.j = this.g.length = 0
}
;
v.Fb = function() {
    for (var a = this.g.length, c = [], d = this.g.length - this.g.length | 0; d < a; d = d + 1 | 0) {
        var e = c
          , f = this.get(d);
        e.push(f)
    }
    return c
}
;
function Jm(a) {
    return 0 == a.g.length ? null : a.get(a.g.length - 1 | 0)
}
function Nm(a, c) {
    if (c >= a.g.length)
        throw a = new eb,
        Wa(a),
        Xa(a, Error(a)),
        a.N;
    return a.g.length < a.o ? c : (a.j + c | 0) % a.o | 0
}
;function Om() {
    this.g = 0
}
var Pm = {}, Qm, Rm, Sm, Tm, Um, Vm, Wm, Xm, Ym, Zm, $m, an, bn, cn, dn, en, fn;
y(Om, B);
function gn(a, c) {
    var d = new Om;
    d.j = a;
    d.g = c;
    Ti(Pm, a, d);
    return d
}
Om.prototype.toString = q("j");
function hn() {
    hn = n();
    Tm = gn("IDLE", 1);
    Um = gn("BUSY", 1);
    Vm = gn("RECOVERING", 2);
    Wm = gn("OFFLINE", 3);
    Xm = gn("SERVER_DOWN", 3);
    Rm = gn("FORBIDDEN", 4);
    Sm = gn("AUTH_REQUIRED", 4);
    Ym = gn("SESSION_LIMIT_EXCEEDED", 5);
    Zm = gn("LOCKED", 5);
    $m = gn("INCOMPATIBLE_SERVER", 5);
    an = gn("CLIENT_ERROR", 5);
    bn = gn("CLIENT_FATAL_ERROR", 5);
    cn = gn("CLIENT_FATAL_ERROR_PENDING_CHANGES", 5);
    gn("BATCH_CLIENT_ERROR", 3);
    gn("SAVE_ERROR", 5);
    dn = gn("DOCUMENT_TOO_LARGE", 5);
    gn("BATCH_SAVE_ERROR", 3);
    en = gn("DOCS_EVERYWHERE_IMPORT_ERROR", 5);
    Qm = gn("POST_LIMIT_EXCEEDED_ERROR", 5);
    fn = gn("DOCS_QUOTA_EXCEEDED_ERROR", 5)
}
;var jn;
function kn() {
    kn = n();
    jn = RegExp("^[^\\[\\{]+")
}
;function ln() {
    this.g = !1;
    this.A = new Sj;
    this.v = new Sj;
    var a = (Dm(),
    ym);
    this.o = new mn(a,null);
    this.j = (hn(),
    Tm);
    Wh(this, this.A);
    Wh(this, this.v);
    Wh(this, this.o)
}
y(ln, Vh);
function nn(a, c) {
    c = c ? c : (hn(),
    an);
    return 401 == a ? (hn(),
    Sm) : 403 == a ? (hn(),
    Rm) : 421 == a ? (hn(),
    Ym) : 423 == a ? (hn(),
    Zm) : 512 == a || 432 == a ? (hn(),
    en) : 433 == a ? (hn(),
    Qm) : 434 == a ? (hn(),
    fn) : 202 == a || 405 == a || 409 == a || 429 == a || 500 <= a && 599 >= a && 550 != a ? (hn(),
    Xm) : 413 == a ? (hn(),
    dn) : 400 <= a && 499 >= a || 550 == a ? c : (hn(),
    Wm)
}
function on(a, c, d, e) {
    var f = a.j;
    if (!isObject(c, f)) {
        a.j = c;
        var g = a.o;
        var h = c.na(Rm) ? (Dm(),
        Bm) : c.na(Sm) ? (Dm(),
        Am) : 5 <= c.g ? (Dm(),
        Cm) : 1 != c.g ? (Dm(),
        zm) : (Dm(),
        ym);
        if (!isObject(g.value, h)) {
            var k = g.value;
            g.value = h;
            g.dispatchEvent(new pn(k,h));
            g.v && Ji(k)
        }
        a.A.dispatchEvent(new qn(f,c,d,e))
    }
}
;function qn() {}
y(qn, B);
function rn(a) {
    Sj.call(this);
    this.value = a
}
y(rn, Sj);
function mn(a, c) {
    rn.call(this, a);
    this.v = !0 === c
}
y(mn, rn);
mn.prototype.K = function() {
    this.v && Ji(this.value);
    rn.prototype.K.call(this)
}
;
function pn(a, c) {
    this.oldValue = a;
    this.newValue = c
}
y(pn, B);
function sn(a, c, d, e) {
    this.j = a;
    this.g = c;
    this.o = d;
    this.v = e
}
y(sn, B);
function tn(a, c, d) {
    if (d.cause instanceof Ua)
        a.o.log(d.j, null, !1);
    else {
        a = a.o;
        var e = D("La`" + d.type + "`" + C(d.g));
        a.log(e, null, !1)
    }
    ai(c, d)
}
function un(a, c, d, e, f) {
    var g = a.g.j.C.createDocument(e, c, 1);
    Fk(g, f.sa());
    W(g, "isFastTrack", tm(a.j));
    ok(g, "acl", a.j.R(), Rb(3));
    var h = rk(3);
    Hk(g, a.j.R(), h);
    Ik(g, xb((new xk).g()));
    if (h = kk(f, "docosKeyData"))
        h[10] = e,
        X(g, "docosKeyData", h);
    W(g, "inc", !0);
    W(g, "hpmdo", !1);
    W(g, "pendingCreation", !0);
    nk(g, "snapshotState", Rb(3));
    a: switch (c) {
    case "kix":
        h = S(a.v, "docs-localstore-endfnd");
        break a;
    default:
        h = !1
    }
    W(g, "ende", h);
    c = new Bl(e,c,!0,-1,[],[],a.g.j.L.o);
    e = ik(g, "odocid") ? [] : f.C ? f.C : [];
    Lk(g, ij(e));
    vn(g, e, Vk(f));
    Gk(g, 1, null);
    nk(g, "pendingQueueState", Rb(1));
    El(c);
    a.g.write([g, c], function() {
        Yh(d, g)
    }, function(k) {
        tn(a, d, k)
    })
}
function vn(a, c, d) {
    if (1 <= d)
        for (d = 0; d < c.length; d = d + 1 | 0)
            Ak(a.j, new Ck(1,null,null,[c[d]],0,Rb(d)), null);
    else
        Ak(a.j, new Ck(1,null,null,c,0,Rb(0)), null)
}
function wn(a, c, d, e) {
    xn(a.g.j.Xa(), c, function(f) {
        yn(a, c, d, e, f)
    }, function(f) {
        tn(a, d, f)
    })
}
function yn(a, c, d, e, f) {
    a.g.j.H.Sb(e, function() {
        un(a, c, d, e, f)
    }, function(g) {
        tn(a, d, g)
    })
}
function zn(a, c) {
    var d = new Xh;
    if (!ol(c, a.v))
        return ai(d, Rk(8, "Create disabled.")),
        d;
    var e = a.g.j.Xa();
    e ? An(e, c, function(f) {
        wn(a, c, d, f)
    }, function(f) {
        tn(a, d, f)
    }) : ai(d, Rk(3, "popUnusedDocumentId not supported."));
    return d
}
;function wk(a) {
    this.g = "offline-oc";
    this.j = a
}
y(wk, hj);
function jj() {}
y(jj, B);
jj.prototype.Z = function(a) {
    if (!ic(a.getType(), "offline-oc"))
        throw D("Ma").N;
    return a.j
}
;
function Bn(a) {
    try {
        var c = jc(a);
        var d = 0 > c ? null : a.substr(c + 1 | 0);
        var e = null == d ? null : decodeURIComponent(d)
    } catch (h) {
        var f = Za(h);
        if (f instanceof db)
            return {};
        throw f.N;
    }
    a = {};
    if (e)
        for (e = e.split("&"),
        d = 0; d < e.length; d++) {
            var g = e[d].split("=");
            2 == g.length && (c = Cn(g[0]),
            g = Cn(g[1]),
            c && g && Ti(a, c, g))
        }
    return a
}
function Cn(a) {
    try {
        return decodeURIComponent(a)
    } catch (d) {
        var c = Za(d);
        if (c instanceof db)
            return null;
        throw c.N;
    }
}
function Dn(a, c) {
    var d = new Tb;
    d.g = "";
    for (var e in c)
        0 < d.g.length && Ub(d, "&"),
        Ub(Ub(Ub(d, encodeURIComponent(e)), "="), encodeURIComponent(C(c[e])));
    c = encodeURIComponent(d.toString());
    d = jc(a);
    return C(0 > d ? a : a.substr(0, d | 0)) + String(c ? "#" + C(c) : "")
}
;var En;
function Fn(a) {
    Gn();
    if (!Hn(a))
        return a;
    var c = String.fromCodePoint(47);
    c = a.indexOf(c, 3);
    return 0 > c ? "" : a.substr(c)
}
function Hn(a) {
    Gn();
    return "/a/" === a.substr(0, 3)
}
function In(a) {
    Gn();
    return a.replace(En, "$1")
}
function Gn() {
    Gn = n();
    En = RegExp("\\/u\\/[0-9]+($|\\/)")
}
;function Jn(a) {
    this.G = G(a, 0, "er")
}
y(Jn, O);
var Kn = dg(Jn);
function Ln(a) {
    return new yk(function() {
        var c = a();
        return Ib(c)
    }
    )
}
;function Mn() {
    function a() {
        f[0] = 1732584193;
        f[1] = 4023233417;
        f[2] = 2562383102;
        f[3] = 271733878;
        f[4] = 3285377520;
        p = m = 0
    }
    function c(r) {
        for (var u = h, w = 0; 64 > w; w += 4)
            u[w / 4] = r[w] << 24 | r[w + 1] << 16 | r[w + 2] << 8 | r[w + 3];
        for (w = 16; 80 > w; w++)
            r = u[w - 3] ^ u[w - 8] ^ u[w - 14] ^ u[w - 16],
            u[w] = (r << 1 | r >>> 31) & 4294967295;
        r = f[0];
        var F = f[1]
          , L = f[2]
          , ra = f[3]
          , cb = f[4];
        for (w = 0; 80 > w; w++) {
            if (40 > w)
                if (20 > w) {
                    var Aa = ra ^ F & (L ^ ra);
                    var bd = 1518500249
                } else
                    Aa = F ^ L ^ ra,
                    bd = 1859775393;
            else
                60 > w ? (Aa = F & L | ra & (F | L),
                bd = 2400959708) : (Aa = F ^ L ^ ra,
                bd = 3395469782);
            Aa = ((r << 5 | r >>> 27) & 4294967295) + Aa + cb + bd + u[w] & 4294967295;
            cb = ra;
            ra = L;
            L = (F << 30 | F >>> 2) & 4294967295;
            F = r;
            r = Aa
        }
        f[0] = f[0] + r & 4294967295;
        f[1] = f[1] + F & 4294967295;
        f[2] = f[2] + L & 4294967295;
        f[3] = f[3] + ra & 4294967295;
        f[4] = f[4] + cb & 4294967295
    }
    function d(r, u) {
        if ("string" === typeof r) {
            r = unescape(encodeURIComponent(r));
            for (var w = [], F = 0, L = r.length; F < L; ++F)
                w.push(r.charCodeAt(F));
            r = w
        }
        u || (u = r.length);
        w = 0;
        if (0 == m)
            for (; w + 64 < u; )
                c(r.slice(w, w + 64)),
                w += 64,
                p += 64;
        for (; w < u; )
            if (g[m++] = r[w++],
            p++,
            64 == m)
                for (m = 0,
                c(g); w + 64 < u; )
                    c(r.slice(w, w + 64)),
                    w += 64,
                    p += 64
    }
    function e() {
        var r = []
          , u = 8 * p;
        56 > m ? d(k, 56 - m) : d(k, 64 - (m - 56));
        for (var w = 63; 56 <= w; w--)
            g[w] = u & 255,
            u >>>= 8;
        c(g);
        for (w = u = 0; 5 > w; w++)
            for (var F = 24; 0 <= F; F -= 8)
                r[u++] = f[w] >> F & 255;
        return r
    }
    for (var f = [], g = [], h = [], k = [128], l = 1; 64 > l; ++l)
        k[l] = 0;
    var m, p;
    a();
    return {
        reset: a,
        update: d,
        digest: e,
        Nc: function() {
            for (var r = e(), u = "", w = 0; w < r.length; w++)
                u += "0123456789ABCDEF".charAt(Math.floor(r[w] / 16)) + "0123456789ABCDEF".charAt(r[w] % 16);
            return u
        }
    }
}
;function Nn(a, c, d) {
    var e = String(z.location.href);
    return e && a && c ? [c, On(ig(e), a, d || null)].join(" ") : null
}
function On(a, c, d) {
    var e = []
      , f = [];
    if (1 == (Array.isArray(d) ? 2 : 1))
        return f = [c, a],
        Rc(e, function(k) {
            f.push(k)
        }),
        Pn(f.join(" "));
    var g = []
      , h = [];
    Rc(d, function(k) {
        h.push(k.key);
        g.push(k.value)
    });
    d = Math.floor((new Date).getTime() / 1E3);
    f = 0 == g.length ? [d, c, a] : [g.join(":"), d, c, a];
    Rc(e, function(k) {
        f.push(k)
    });
    a = Pn(f.join(" "));
    a = [d, a];
    0 == h.length || a.push(h.join(""));
    return a.join("_")
}
function Pn(a) {
    var c = Mn();
    c.update(a);
    return c.Nc().toLowerCase()
}
;var Qn = {};
function Rn() {
    this.g = document || {
        cookie: ""
    }
}
Rn.prototype.set = function(a, c, d) {
    var e = !1;
    if ("object" === typeof d) {
        var f = d.ce;
        e = d.de || !1;
        var g = d.domain || void 0;
        var h = d.path || void 0;
        var k = d.hd
    }
    if (/[;=\s]/.test(a))
        throw Error("Na`" + a);
    if (/[;\r\n]/.test(c))
        throw Error("Oa`" + c);
    void 0 === k && (k = -1);
    this.g.cookie = a + "=" + c + (g ? ";domain=" + g : "") + (h ? ";path=" + h : "") + (0 > k ? "" : 0 == k ? ";expires=" + (new Date(1970,1,1)).toUTCString() : ";expires=" + (new Date(Date.now() + 1E3 * k)).toUTCString()) + (e ? ";secure" : "") + (null != f ? ";samesite=" + f : "")
}
;
Rn.prototype.get = function(a, c) {
    for (var d = a + "=", e = (this.g.cookie || "").split(";"), f = 0, g; f < e.length; f++) {
        g = nc(e[f]);
        if (0 == g.lastIndexOf(d, 0))
            return g.slice(d.length);
        if (g == a)
            return ""
    }
    return c
}
;
Rn.prototype.Fb = function() {
    return Sn(this).values
}
;
Rn.prototype.clear = function() {
    for (var a = Sn(this).keys, c = a.length - 1; 0 <= c; c--) {
        var d = a[c];
        this.get(d);
        this.set(d, "", {
            hd: 0,
            path: void 0,
            domain: void 0
        })
    }
}
;
function Sn(a) {
    a = (a.g.cookie || "").split(";");
    for (var c = [], d = [], e, f, g = 0; g < a.length; g++)
        f = nc(a[g]),
        e = f.indexOf("="),
        -1 == e ? (c.push(""),
        d.push(f)) : (c.push(f.substring(0, e)),
        d.push(f.substring(e + 1)));
    return {
        keys: c,
        values: d
    }
}
;function Tn(a) {
    return !!Qn.FPA_SAMESITE_PHASE2_MOD || !(void 0 === a || !a)
}
function Un(a, c, d, e) {
    (a = z[a]) || "undefined" === typeof document || (a = (new Rn).get(c));
    return a ? Nn(a, d, e) : null
}
function Vn(a, c) {
    c = void 0 === c ? !1 : c;
    var d = ig(String(z.location.href))
      , e = [];
    var f = c;
    f = void 0 === f ? !1 : f;
    var g = z.__SAPISID || z.__APISID || z.__3PSAPISID || z.__OVERRIDE_SID;
    Tn(f) && (g = g || z.__1PSAPISID);
    if (g)
        f = !0;
    else {
        if ("undefined" !== typeof document) {
            var h = new Rn;
            g = h.get("SAPISID") || h.get("APISID") || h.get("__Secure-3PAPISID") || h.get("SID") || h.get("OSID");
            Tn(f) && (g = g || h.get("__Secure-1PAPISID"))
        }
        f = !!g
    }
    f && (f = (d = 0 == d.indexOf("https:") || 0 == d.indexOf("chrome-extension:") || 0 == d.indexOf("moz-extension:")) ? z.__SAPISID : z.__APISID,
    f || "undefined" === typeof document || (f = new Rn,
    f = f.get(d ? "SAPISID" : "APISID") || f.get("__Secure-3PAPISID")),
    (f = f ? Nn(f, d ? "SAPISIDHASH" : "APISIDHASH", a) : null) && e.push(f),
    d && Tn(c) && ((c = Un("__1PSAPISID", "__Secure-1PAPISID", "SAPISID1PHASH", a)) && e.push(c),
    (a = Un("__3PSAPISID", "__Secure-3PAPISID", "SAPISID3PHASH", a)) && e.push(a)));
    return 0 == e.length ? null : e.join(" ")
}
;function Wn(a) {
    if (!a)
        return null;
    try {
        var c = parseInt(a, 10);
        return isNaN(c) ? null : c
    } catch (d) {
        return null
    }
}
;function Xn(a) {
    return (a = wi(a, "gxids")) ? a.split(",").map(function(c) {
        return Wn(c)
    }).filter(function(c) {
        return null != c && 0 < c
    }) : []
}
;function Yn(a) {
    this.o = a.slice();
    this.g = [];
    this.j = !1
}
function Zn(a) {
    if (a.j)
        throw Error("Pa");
    a.j = !0;
    return (new Promise(function(c) {
        for (var d = 0; 5 > d; d++)
            $n(a, c)
    }
    )).then(function() {
        return Promise.allSettled(a.g).then(function() {
            return Promise.all(a.g)
        })
    })
}
function $n(a, c) {
    if (0 == a.o.length)
        c();
    else {
        var d = a.o.shift()
          , e = Promise.resolve().then(function() {
            return d()
        });
        a.g.push(e);
        var f = function() {
            $n(a, c)
        };
        e.then(f, f)
    }
}
;function ao(a) {
    try {
        var c = z.localStorage.getItem("docs-oiouid") || null
    } catch (d) {
        c = null
    }
    return T(a, "docs-offline-lsuid") == c
}
;function bo(a, c) {
    this.j = this.B = this.v = "";
    this.C = null;
    this.D = this.o = "";
    this.A = !1;
    var d;
    a instanceof bo ? (this.A = void 0 !== c ? c : a.A,
    co(this, a.v),
    this.B = a.B,
    this.j = a.j,
    eo(this, a.C),
    fo(this, a.o),
    go(this, ho(a.g)),
    io(this, a.D)) : a && (d = ji(String(a))) ? (this.A = !!c,
    co(this, d[1] || "", !0),
    this.B = jo(d[2] || ""),
    this.j = jo(d[3] || "", !0),
    eo(this, d[4]),
    fo(this, d[5] || "", !0),
    go(this, d[6] || "", !0),
    io(this, d[7] || "", !0)) : (this.A = !!c,
    this.g = new ko(null,this.A))
}
bo.prototype.toString = function() {
    var a = []
      , c = this.v;
    c && a.push(lo(c, mo, !0), ":");
    var d = this.j;
    if (d || "file" == c)
        a.push("//"),
        (c = this.B) && a.push(lo(c, mo, !0), "@"),
        a.push(encodeURIComponent(String(d)).replace(/%25([0-9a-fA-F]{2})/g, "%$1")),
        d = this.C,
        null != d && a.push(":", String(d));
    if (d = this.o)
        this.j && "/" != d.charAt(0) && a.push("/"),
        a.push(lo(d, "/" == d.charAt(0) ? no : oo, !0));
    (d = this.g.toString()) && a.push("?", d);
    (d = this.D) && a.push("#", lo(d, po));
    return a.join("")
}
;
bo.prototype.resolve = function(a) {
    var c = new bo(this)
      , d = !!a.v;
    d ? co(c, a.v) : d = !!a.B;
    d ? c.B = a.B : d = !!a.j;
    d ? c.j = a.j : d = null != a.C;
    var e = a.o;
    if (d)
        eo(c, a.C);
    else if (d = !!a.o) {
        if ("/" != e.charAt(0))
            if (this.j && !this.o)
                e = "/" + e;
            else {
                var f = c.o.lastIndexOf("/");
                -1 != f && (e = c.o.slice(0, f + 1) + e)
            }
        f = e;
        if (".." == f || "." == f)
            e = "";
        else if (-1 != f.indexOf("./") || -1 != f.indexOf("/.")) {
            e = lc(f, "/");
            f = f.split("/");
            for (var g = [], h = 0; h < f.length; ) {
                var k = f[h++];
                "." == k ? e && h == f.length && g.push("") : ".." == k ? ((1 < g.length || 1 == g.length && "" != g[0]) && g.pop(),
                e && h == f.length && g.push("")) : (g.push(k),
                e = !0)
            }
            e = g.join("/")
        } else
            e = f
    }
    d ? fo(c, e) : d = "" !== a.g.toString();
    d ? go(c, ho(a.g)) : d = !!a.D;
    d && io(c, a.D);
    return c
}
;
function co(a, c, d) {
    a.v = d ? jo(c, !0) : c;
    a.v && (a.v = a.v.replace(/:$/, ""))
}
function eo(a, c) {
    if (c) {
        c = Number(c);
        if (isNaN(c) || 0 > c)
            throw Error("Qa`" + c);
        a.C = c
    } else
        a.C = null
}
function fo(a, c, d) {
    a.o = d ? jo(c, !0) : c;
    return a
}
function go(a, c, d) {
    c instanceof ko ? (a.g = c,
    qo(a.g, a.A)) : (d || (c = lo(c, ro)),
    a.g = new ko(c,a.A));
    return a
}
function io(a, c, d) {
    a.D = d ? jo(c) : c;
    return a
}
function so(a) {
    return a instanceof bo ? new bo(a) : new bo(a,void 0)
}
function jo(a, c) {
    return a ? c ? decodeURI(a.replace(/%25/g, "%2525")) : decodeURIComponent(a) : ""
}
function lo(a, c, d) {
    return "string" === typeof a ? (a = encodeURI(a).replace(c, to),
    d && (a = a.replace(/%25([0-9a-fA-F]{2})/g, "%$1")),
    a) : null
}
function to(a) {
    a = a.charCodeAt(0);
    return "%" + (a >> 4 & 15).toString(16) + (a & 15).toString(16)
}
var mo = /[#\/\?@]/g
  , oo = /[#\?:]/g
  , no = /[#\?]/g
  , ro = /[#\?@]/g
  , po = /#/g;
function ko(a, c) {
    this.j = this.g = null;
    this.o = a || null;
    this.v = !!c
}
function uo(a) {
    a.g || (a.g = new Map,
    a.j = 0,
    a.o && mi(a.o, function(c, d) {
        a.add(decodeURIComponent(c.replace(/\+/g, " ")), d)
    }))
}
v = ko.prototype;
v.add = function(a, c) {
    uo(this);
    this.o = null;
    a = vo(this, a);
    var d = this.g.get(a);
    d || this.g.set(a, d = []);
    d.push(c);
    this.j = this.j + 1;
    return this
}
;
function wo(a, c) {
    uo(a);
    c = vo(a, c);
    a.g.has(c) && (a.o = null,
    a.j = a.j - a.g.get(c).length,
    a.g.delete(c))
}
v.clear = function() {
    this.g = this.o = null;
    this.j = 0
}
;
function xo(a, c) {
    uo(a);
    c = vo(a, c);
    return a.g.has(c)
}
v.forEach = function(a, c) {
    uo(this);
    this.g.forEach(function(d, e) {
        d.forEach(function(f) {
            a.call(c, f, e, this)
        }, this)
    }, this)
}
;
v.Fb = function(a) {
    uo(this);
    var c = [];
    if ("string" === typeof a)
        xo(this, a) && (c = c.concat(this.g.get(vo(this, a))));
    else {
        a = Array.from(this.g.values());
        for (var d = 0; d < a.length; d++)
            c = c.concat(a[d])
    }
    return c
}
;
v.set = function(a, c) {
    uo(this);
    this.o = null;
    a = vo(this, a);
    xo(this, a) && (this.j = this.j - this.g.get(a).length);
    this.g.set(a, [c]);
    this.j = this.j + 1;
    return this
}
;
v.get = function(a, c) {
    if (!a)
        return c;
    a = this.Fb(a);
    return 0 < a.length ? String(a[0]) : c
}
;
v.toString = function() {
    if (this.o)
        return this.o;
    if (!this.g)
        return "";
    for (var a = [], c = Array.from(this.g.keys()), d = 0; d < c.length; d++) {
        var e = c[d]
          , f = encodeURIComponent(String(e));
        e = this.Fb(e);
        for (var g = 0; g < e.length; g++) {
            var h = f;
            "" !== e[g] && (h += "=" + encodeURIComponent(String(e[g])));
            a.push(h)
        }
    }
    return this.o = a.join("&")
}
;
function ho(a) {
    var c = new ko;
    c.o = a.o;
    a.g && (c.g = new Map(a.g),
    c.j = a.j);
    return c
}
function vo(a, c) {
    c = String(c);
    a.v && (c = c.toLowerCase());
    return c
}
function qo(a, c) {
    c && !a.v && (uo(a),
    a.o = null,
    a.g.forEach(function(d, e) {
        var f = e.toLowerCase();
        e != f && (wo(this, e),
        wo(this, f),
        0 < d.length && (this.o = null,
        this.g.set(vo(this, f), Vc(d)),
        this.j = this.j + d.length))
    }, a));
    a.v = c
}
;function yo() {
    var a = new bo(z.location.href);
    return "true" == a.g.get("Debug") || "true" == a.g.get("debug") || "pretty" == a.g.get("debug") || "DU" == a.g.get("jsmode")
}
function zo(a, c) {
    var d = a.indexOf("#");
    d = 0 > d ? null : a.slice(d + 1);
    a = yi(li(a), c);
    return li(a) + (d ? "#" + d : "")
}
var Ao = ["/preview", "/htmlview"];
function Bo(a) {
    this.G = G(a)
}
y(Bo, O);
function Co() {
    var a = z.window;
    a.onbeforeunload = n();
    a.location.reload()
}
;function Do() {
    this.g = function() {
        Co()
    }
}
Do.prototype.notify = function() {
    window.confirm("This error has been reported to Google and we'll look into it as soon as possible. Please reload this page to continue.") && this.g()
}
;
var Eo = /\/d\/([^\/]+)/
  , Fo = /\/r\/([^\/]+)/;
function Go(a) {
    a = ji(a)[5] || null;
    return Eo.test(a)
}
function Ho(a, c) {
    if (Go(a)) {
        Go(a);
        a = ji(a);
        var d = a[5];
        d = d.replace(c, "");
        c = hi(a[1], a[2], a[3], a[4], d, a[6], a[7])
    } else
        c = a;
    return c
}
;function Io(a, c) {
    this.type = a;
    this.o = this.target = c;
    this.defaultPrevented = this.v = !1
}
Io.prototype.stopPropagation = function() {
    this.v = !0
}
;
Io.prototype.A = function() {
    this.defaultPrevented = !0
}
;
var Jo = function() {
    if (!z.addEventListener || !Object.defineProperty)
        return !1;
    var a = !1
      , c = Object.defineProperty({}, "passive", {
        get: function() {
            a = !0
        }
    });
    try {
        var d = n();
        z.addEventListener("test", d, c);
        z.removeEventListener("test", d, c)
    } catch (e) {}
    return a
}();
function Ko(a, c) {
    Io.call(this, a ? a.type : "");
    this.relatedTarget = this.o = this.target = null;
    this.button = this.screenY = this.screenX = this.clientY = this.clientX = 0;
    this.key = "";
    this.metaKey = this.shiftKey = this.altKey = this.ctrlKey = !1;
    this.state = null;
    this.pointerId = 0;
    this.pointerType = "";
    this.g = null;
    a && this.init(a, c)
}
Ka(Ko, Io);
var Lo = {
    2: "touch",
    3: "pen",
    4: "mouse"
};
Ko.prototype.init = function(a, c) {
    var d = this.type = a.type
      , e = a.changedTouches && a.changedTouches.length ? a.changedTouches[0] : null;
    this.target = a.target || a.srcElement;
    this.o = c;
    c = a.relatedTarget;
    c || ("mouseover" == d ? c = a.fromElement : "mouseout" == d && (c = a.toElement));
    this.relatedTarget = c;
    e ? (this.clientX = void 0 !== e.clientX ? e.clientX : e.pageX,
    this.clientY = void 0 !== e.clientY ? e.clientY : e.pageY,
    this.screenX = e.screenX || 0,
    this.screenY = e.screenY || 0) : (this.clientX = void 0 !== a.clientX ? a.clientX : a.pageX,
    this.clientY = void 0 !== a.clientY ? a.clientY : a.pageY,
    this.screenX = a.screenX || 0,
    this.screenY = a.screenY || 0);
    this.button = a.button;
    this.key = a.key || "";
    this.ctrlKey = a.ctrlKey;
    this.altKey = a.altKey;
    this.shiftKey = a.shiftKey;
    this.metaKey = a.metaKey;
    this.pointerId = a.pointerId || 0;
    this.pointerType = "string" === typeof a.pointerType ? a.pointerType : Lo[a.pointerType] || "";
    this.state = a.state;
    this.g = a;
    a.defaultPrevented && Ko.ua.A.call(this)
}
;
Ko.prototype.stopPropagation = function() {
    Ko.ua.stopPropagation.call(this);
    this.g.stopPropagation ? this.g.stopPropagation() : this.g.cancelBubble = !0
}
;
Ko.prototype.A = function() {
    Ko.ua.A.call(this);
    var a = this.g;
    a.preventDefault ? a.preventDefault() : a.returnValue = !1
}
;
var Mo = "closure_listenable_" + (1E6 * Math.random() | 0);
function No(a) {
    return !(!a || !a[Mo])
}
;var Oo = 0;
function Po(a, c, d, e, f) {
    this.listener = a;
    this.proxy = null;
    this.src = c;
    this.type = d;
    this.capture = !!e;
    this.Hb = f;
    this.key = ++Oo;
    this.ub = this.Ga = !1
}
function Qo(a) {
    a.ub = !0;
    a.listener = null;
    a.proxy = null;
    a.src = null;
    a.Hb = null
}
;function Ro(a) {
    this.src = a;
    this.g = {};
    this.j = 0
}
Ro.prototype.add = function(a, c, d, e, f) {
    var g = a.toString();
    a = this.g[g];
    a || (a = this.g[g] = [],
    this.j++);
    var h = So(a, c, e, f);
    -1 < h ? (c = a[h],
    d || (c.Ga = !1)) : (c = new Po(c,this.src,g,!!e,f),
    c.Ga = d,
    a.push(c));
    return c
}
;
function To(a, c) {
    var d = c.type;
    d in a.g && Uc(a.g[d], c) && (Qo(c),
    0 == a.g[d].length && (delete a.g[d],
    a.j--))
}
function Uo(a, c, d, e, f) {
    a = a.g[c.toString()];
    c = -1;
    a && (c = So(a, d, e, f));
    return -1 < c ? a[c] : null
}
function So(a, c, d, e) {
    for (var f = 0; f < a.length; ++f) {
        var g = a[f];
        if (!g.ub && g.listener == c && g.capture == !!d && g.Hb == e)
            return f
    }
    return -1
}
;var Vo = "closure_lm_" + (1E6 * Math.random() | 0)
  , Wo = {}
  , Xo = 0;
function Yo(a, c, d, e, f) {
    if (e && e.once)
        return Zo(a, c, d, e, f);
    if (Array.isArray(c)) {
        for (var g = 0; g < c.length; g++)
            Yo(a, c[g], d, e, f);
        return null
    }
    d = $o(d);
    return No(a) ? a.j.add(String(c), d, !1, Ca(e) ? !!e.capture : !!e, f) : ap(a, c, d, !1, e, f)
}
function ap(a, c, d, e, f, g) {
    if (!c)
        throw Error("Sa");
    var h = Ca(f) ? !!f.capture : !!f
      , k = bp(a);
    k || (a[Vo] = k = new Ro(a));
    d = k.add(c, d, e, h, g);
    if (d.proxy)
        return d;
    e = cp();
    d.proxy = e;
    e.src = a;
    e.listener = d;
    if (a.addEventListener)
        Jo || (f = h),
        void 0 === f && (f = !1),
        a.addEventListener(c.toString(), e, f);
    else if (a.attachEvent)
        a.attachEvent(dp(c.toString()), e);
    else if (a.addListener && a.removeListener)
        a.addListener(e);
    else
        throw Error("Ta");
    Xo++;
    return d
}
function cp() {
    function a(d) {
        return c.call(a.src, a.listener, d)
    }
    var c = ep;
    return a
}
function Zo(a, c, d, e, f) {
    if (Array.isArray(c)) {
        for (var g = 0; g < c.length; g++)
            Zo(a, c[g], d, e, f);
        return null
    }
    d = $o(d);
    return No(a) ? a.j.add(String(c), d, !0, Ca(e) ? !!e.capture : !!e, f) : ap(a, c, d, !0, e, f)
}
function fp(a, c, d, e, f) {
    if (Array.isArray(c))
        for (var g = 0; g < c.length; g++)
            fp(a, c[g], d, e, f);
    else
        e = Ca(e) ? !!e.capture : !!e,
        d = $o(d),
        No(a) ? (a = a.j,
        c = String(c).toString(),
        c in a.g && (g = a.g[c],
        d = So(g, d, e, f),
        -1 < d && (Qo(g[d]),
        Array.prototype.splice.call(g, d, 1),
        0 == g.length && (delete a.g[c],
        a.j--)))) : a && (a = bp(a)) && (d = Uo(a, c, d, e, f)) && gp(d)
}
function gp(a) {
    if ("number" !== typeof a && a && !a.ub) {
        var c = a.src;
        if (No(c))
            To(c.j, a);
        else {
            var d = a.type
              , e = a.proxy;
            c.removeEventListener ? c.removeEventListener(d, e, a.capture) : c.detachEvent ? c.detachEvent(dp(d), e) : c.addListener && c.removeListener && c.removeListener(e);
            Xo--;
            (d = bp(c)) ? (To(d, a),
            0 == d.j && (d.src = null,
            c[Vo] = null)) : Qo(a)
        }
    }
}
function dp(a) {
    return a in Wo ? Wo[a] : Wo[a] = "on" + a
}
function ep(a, c) {
    if (a.ub)
        a = !0;
    else {
        c = new Ko(c,this);
        var d = a.listener
          , e = a.Hb || a.src;
        a.Ga && gp(a);
        a = d.call(e, c)
    }
    return a
}
function bp(a) {
    a = a[Vo];
    return a instanceof Ro ? a : null
}
var hp = "__closure_events_fn_" + (1E9 * Math.random() >>> 0);
function $o(a) {
    if ("function" === typeof a)
        return a;
    a[hp] || (a[hp] = function(c) {
        return a.handleEvent(c)
    }
    );
    return a[hp]
}
pg(function(a) {
    ep = a(ep)
});
function Y() {
    Q.call(this);
    this.j = new Ro(this);
    this.lb = this;
    this.V = null
}
Ka(Y, Q);
Y.prototype[Mo] = !0;
Y.prototype.addEventListener = function(a, c, d, e) {
    Yo(this, a, c, d, e)
}
;
Y.prototype.removeEventListener = function(a, c, d, e) {
    fp(this, a, c, d, e)
}
;
Y.prototype.dispatchEvent = function(a) {
    var c = this.V;
    if (c) {
        var d = [];
        for (var e = 1; c; c = c.V)
            d.push(c),
            ++e
    }
    c = this.lb;
    e = a.type || a;
    if ("string" === typeof a)
        a = new Io(a,c);
    else if (a instanceof Io)
        a.target = a.target || c;
    else {
        var f = a;
        a = new Io(e,c);
        Bg(a, f)
    }
    f = !0;
    if (d)
        for (var g = d.length - 1; !a.v && 0 <= g; g--) {
            var h = a.o = d[g];
            f = ip(h, e, !0, a) && f
        }
    a.v || (h = a.o = c,
    f = ip(h, e, !0, a) && f,
    a.v || (f = ip(h, e, !1, a) && f));
    if (d)
        for (g = 0; !a.v && g < d.length; g++)
            h = a.o = d[g],
            f = ip(h, e, !1, a) && f;
    return f
}
;
Y.prototype.K = function() {
    Y.ua.K.call(this);
    if (this.j) {
        var a = this.j, c = 0, d;
        for (d in a.g) {
            for (var e = a.g[d], f = 0; f < e.length; f++)
                ++c,
                Qo(e[f]);
            delete a.g[d];
            a.j--
        }
    }
    this.V = null
}
;
function ip(a, c, d, e) {
    c = a.j.g[String(c)];
    if (!c)
        return !0;
    c = c.concat();
    for (var f = !0, g = 0; g < c.length; ++g) {
        var h = c[g];
        if (h && !h.ub && h.capture == d) {
            var k = h.listener
              , l = h.Hb || h.src;
            h.Ga && To(a.j, h);
            f = !1 !== k.call(l, e) && f
        }
    }
    return f && !e.defaultPrevented
}
;function jp(a, c) {
    Y.call(this);
    this.o = a || 1;
    this.g = c || z;
    this.v = A(this.pd, this);
    this.A = Date.now()
}
Ka(jp, Y);
v = jp.prototype;
v.enabled = !1;
v.xa = null;
v.setInterval = function(a) {
    this.o = a;
    this.xa && this.enabled ? (this.stop(),
    this.start()) : this.xa && this.stop()
}
;
v.pd = function() {
    if (this.enabled) {
        var a = Date.now() - this.A;
        0 < a && a < .8 * this.o ? this.xa = this.g.setTimeout(this.v, this.o - a) : (this.xa && (this.g.clearTimeout(this.xa),
        this.xa = null),
        this.dispatchEvent("tick"),
        this.enabled && (this.stop(),
        this.start()))
    }
}
;
v.start = function() {
    this.enabled = !0;
    this.xa || (this.xa = this.g.setTimeout(this.v, this.o),
    this.A = Date.now())
}
;
v.stop = function() {
    this.enabled = !1;
    this.xa && (this.g.clearTimeout(this.xa),
    this.xa = null)
}
;
v.K = function() {
    jp.ua.K.call(this);
    this.stop();
    delete this.g
}
;
function kp(a, c, d) {
    if ("function" === typeof a)
        d && (a = A(a, d));
    else if (a && "function" == typeof a.handleEvent)
        a = A(a.handleEvent, a);
    else
        throw Error("Ua");
    return 2147483647 < Number(c) ? -1 : z.setTimeout(a, c || 0)
}
function lp(a) {
    var c = null;
    return (new dh(function(d, e) {
        c = kp(function() {
            d(void 0)
        }, a);
        -1 == c && e(Error("Va"))
    }
    )).Aa(function(d) {
        z.clearTimeout(c);
        throw d;
    })
}
;function mp(a, c, d) {
    Q.call(this);
    this.g = a;
    this.o = c || 0;
    this.j = d;
    this.v = A(this.Ec, this)
}
Ka(mp, Q);
v = mp.prototype;
v.kb = 0;
v.K = function() {
    mp.ua.K.call(this);
    this.stop();
    delete this.g;
    delete this.j
}
;
v.start = function(a) {
    this.stop();
    this.kb = kp(this.v, void 0 !== a ? a : this.o)
}
;
v.stop = function() {
    this.isActive() && z.clearTimeout(this.kb);
    this.kb = 0
}
;
v.isActive = function() {
    return 0 != this.kb
}
;
v.Ec = function() {
    this.kb = 0;
    this.g && this.g.call(this.j)
}
;
function np(a) {
    Q.call(this);
    this.j = a;
    this.g = {}
}
Ka(np, Q);
var op = [];
function qp(a, c, d, e) {
    Array.isArray(d) || (d && (op[0] = d.toString()),
    d = op);
    for (var f = 0; f < d.length; f++) {
        var g = Yo(c, d[f], e || a.handleEvent, !1, a.j || a);
        if (!g)
            break;
        a.g[g.key] = g
    }
}
function rp(a, c, d) {
    sp(a, c, "complete", d)
}
function sp(a, c, d, e, f, g) {
    if (Array.isArray(d))
        for (var h = 0; h < d.length; h++)
            sp(a, c, d[h], e, f, g);
    else
        (c = Zo(c, d, e || a.handleEvent, f, g || a.j || a)) && (a.g[c.key] = c)
}
function tp(a, c, d, e, f, g) {
    if (Array.isArray(d))
        for (var h = 0; h < d.length; h++)
            tp(a, c, d[h], e, f, g);
    else
        e = e || a.handleEvent,
        f = Ca(f) ? !!f.capture : !!f,
        g = g || a.j || a,
        e = $o(e),
        f = !!f,
        d = No(c) ? Uo(c.j, String(d), e, f, g) : c ? (c = bp(c)) ? Uo(c, d, e, f, g) : null : null,
        d && (gp(d),
        delete a.g[d.key])
}
function up(a) {
    tg(a.g, function(c, d) {
        this.g.hasOwnProperty(d) && gp(c)
    }, a);
    a.g = {}
}
np.prototype.K = function() {
    np.ua.K.call(this);
    up(this)
}
;
np.prototype.handleEvent = function() {
    throw Error("Wa");
}
;
function vp(a, c, d, e) {
    Q.call(this);
    this.j = a;
    this.S = c;
    this.D = new mp(this.B,3E4,this);
    this.O = new Em("errorsender",1,8,e);
    R(this, this.O);
    this.M = !1;
    this.J = null;
    this.H = new Set;
    this.I = new np(this);
    this.fa = d || 10;
    qp(this.I, this.j, "complete", this.V);
    qp(this.I, this.j, "ready", this.B)
}
y(vp, Q);
vp.prototype.send = function(a, c, d, e) {
    S(this.S, "docs-dafjera") && (a = Ho(Ho(a, Fo), Eo));
    var f = Jh(Jh(this.fb(), function(g) {
        if (!(g >= this.fa))
            return g = {},
            g.u = a,
            g.m = c,
            g.c = d,
            g.h = e,
            this.zb(g)
    }, this), this.B, this);
    Lh(f, function() {
        this.H.delete(f)
    }, this);
    this.H.add(f)
}
;
function wp(a) {
    return nh(Array.from(a.H.values())).then(n())
}
vp.prototype.B = function() {
    return this.D.isActive() || this.j.isActive() || this.M ? Qh() : xp(this)
}
;
function xp(a) {
    a.D.isActive();
    a.j.isActive();
    return Jh(a.cb(), function(c) {
        if (!(this.j.isActive() || this.D.isActive() || this.M) && c) {
            if (4E3 < c.u.length)
                return this.Oa();
            try {
                return Hm(this.O),
                this.J = new Ch,
                this.j.send(c.u, c.m, c.c, c.h),
                this.J
            } catch (d) {
                c = d;
                if (null == c)
                    c = new Ua,
                    Wa(c),
                    Xa(c, Error(c));
                else if (!(c instanceof Ua))
                    if (c instanceof Error)
                        c = Za(c);
                    else
                        throw Pb("ja").N;
                if (c instanceof wm)
                    this.M = !0;
                else
                    throw Gi(d, {
                        "docs-origin-class": "docs.debug.ErrorSender"
                    });
            }
        }
    }, a)
}
vp.prototype.V = function() {
    var a = this.j.Ka()
      , c = this.J;
    this.j.Ua() || 400 <= a && 500 >= a ? Jh(this.Oa(), function() {
        c.qa()
    }) : (this.D.start(),
    c.qa())
}
;
vp.prototype.K = function() {
    Ki(this.I, this.D, this.j);
    this.H.clear();
    Q.prototype.K.call(this)
}
;
function yp(a, c, d) {
    vp.call(this, a, c, d);
    this.g = []
}
y(yp, vp);
v = yp.prototype;
v.zb = function(a) {
    this.g.push(a);
    return Qh()
}
;
v.Oa = function() {
    this.g.shift();
    return Qh()
}
;
v.cb = function() {
    return Qh(void 0 !== this.g[0] ? this.g[0] : null)
}
;
v.fb = function() {
    return Qh(this.g.length)
}
;
v.K = function() {
    delete this.g;
    vp.prototype.K.call(this)
}
;
function zp(a, c) {
    this.g = a;
    this.j = c
}
zp.prototype.o = function(a) {
    this.g && (this.g.call(this.j || null, a),
    this.g = this.j = null)
}
;
zp.prototype.abort = function() {
    this.j = this.g = null
}
;
pg(function(a) {
    zp.prototype.o = a(zp.prototype.o)
});
function Ap(a) {
    this.g = new jg(a);
    a = nf(this.g, 1, 0);
    this.j = Math.floor(100 * Math.random()) < a
}
Ap.prototype.toString = function() {
    var a = this.j ? jf(this.g, 6) : of(this.g, 3, "");
    a = "{bool=" + !(this.j ? !mf(this.g, 5) : !mf(this.g, 2, !1)) + ', string="' + (null != a ? String(a) : "") + '", int=';
    var c = this.j ? se(Re(this.g, 7)) : nf(this.g, 4, -1);
    return a + (null != c ? Number(c) : -1) + "}"
}
;
function Bp(a) {
    this.g = new Map;
    this.j = [];
    if (a = a.get("docs-cei")) {
        var c = a.i;
        c && Wc(this.j, c);
        a = a.cf || {};
        for (var d in a)
            this.g.set(d, new Ap(a[d]))
    }
}
Bp.prototype.get = function(a) {
    return this.g.get(a) || null
}
;
function Cp() {
    for (var a in Array.prototype)
        return !1;
    return !0
}
;function Dp(a) {
    Q.call(this);
    this.j = a
}
Ka(Dp, Q);
Dp.prototype.g = function(a) {
    return Ep(this, a)
}
;
function Fp(a, c) {
    return (c ? "__wrapper_" : "__protected_") + Da(a) + "__"
}
function Ep(a, c) {
    var d = Fp(a, !0);
    c[d] || ((c[d] = Gp(a, c))[Fp(a, !1)] = c);
    return c[d]
}
function Gp(a, c) {
    function d() {
        if (a.wa())
            return c.apply(this, arguments);
        try {
            return c.apply(this, arguments)
        } catch (e) {
            Hp(a, e)
        }
    }
    d[Fp(a, !1)] = c;
    return d
}
function Hp(a, c) {
    if (!(c && "object" === typeof c && "string" === typeof c.message && 0 == c.message.indexOf("Error in protected function: ") || "string" === typeof c && 0 == c.indexOf("Error in protected function: ")))
        throw a.j(c),
        new Ip(c);
}
function Jp(a) {
    var c = c || z.window || z.globalThis;
    "onunhandledrejection"in c && (c.onunhandledrejection = function(d) {
        Hp(a, d && d.reason ? d.reason : Error("Ya"))
    }
    )
}
function Kp(a, c) {
    var d = z.window || z.globalThis
      , e = d[c];
    if (!e)
        throw Error("Za`" + c);
    d[c] = function(f, g) {
        "string" === typeof f && (f = Ia(Ja, f));
        f && (arguments[0] = f = Ep(a, f));
        if (e.apply)
            return e.apply(this, arguments);
        var h = f;
        if (2 < arguments.length) {
            var k = Array.prototype.slice.call(arguments, 2);
            h = function() {
                f.apply(this, k)
            }
        }
        return e(h, g)
    }
    ;
    d[c][Fp(a, !1)] = e
}
Dp.prototype.K = function() {
    var a = z.window || z.globalThis;
    var c = a.setTimeout;
    c = c[Fp(this, !1)] || c;
    a.setTimeout = c;
    c = a.setInterval;
    c = c[Fp(this, !1)] || c;
    a.setInterval = c;
    Dp.ua.K.call(this)
}
;
function Ip(a) {
    tb.call(this, "Error in protected function: " + (a && a.message ? String(a.message) : String(a)), a);
    (a = a && a.stack) && "string" === typeof a && (this.stack = a)
}
Ka(Ip, tb);
function Lp() {}
Lp.prototype.o = null;
function Mp(a) {
    return a.o || (a.o = a.v())
}
;var Np;
function Op() {}
Ka(Op, Lp);
Op.prototype.j = function() {
    var a = Pp(this);
    return a ? new ActiveXObject(a) : new XMLHttpRequest
}
;
Op.prototype.v = function() {
    var a = {};
    Pp(this) && (a[0] = !0,
    a[1] = !0);
    return a
}
;
function Pp(a) {
    if (!a.g && "undefined" == typeof XMLHttpRequest && "undefined" != typeof ActiveXObject) {
        for (var c = ["MSXML2.XMLHTTP.6.0", "MSXML2.XMLHTTP.3.0", "MSXML2.XMLHTTP", "Microsoft.XMLHTTP"], d = 0; d < c.length; d++) {
            var e = c[d];
            try {
                return new ActiveXObject(e),
                a.g = e
            } catch (f) {}
        }
        throw Error("$a");
    }
    return a.g
}
Np = new Op;
function Qp(a) {
    Y.call(this);
    this.headers = new Map;
    this.M = a || null;
    this.o = !1;
    this.J = this.g = null;
    this.S = "";
    this.B = 0;
    this.v = this.P = this.H = this.O = !1;
    this.D = 0;
    this.I = null;
    this.A = "";
    this.W = this.F = !1
}
Ka(Qp, Y);
var Rp = /^https?$/i
  , Sp = ["POST", "PUT"]
  , Tp = [];
function Up(a, c, d, e, f, g, h) {
    var k = new Qp;
    Tp.push(k);
    c && k.j.add("complete", c, !1, void 0, void 0);
    k.j.add("ready", k.Kc, !0, void 0, void 0);
    g && (k.D = Math.max(0, g));
    h && (k.F = h);
    k.send(a, d, e, f)
}
v = Qp.prototype;
v.Kc = function() {
    this.X();
    Uc(Tp, this)
}
;
v.send = function(a, c, d, e) {
    if (this.g)
        throw Error("ab`" + this.S + "`" + a);
    c = c ? c.toUpperCase() : "GET";
    this.S = a;
    this.B = 0;
    this.O = !1;
    this.o = !0;
    this.g = this.M ? this.M.j() : Np.j();
    this.J = this.M ? Mp(this.M) : Mp(Np);
    this.g.onreadystatechange = A(this.Ac, this);
    try {
        this.P = !0,
        this.g.open(c, String(a), !0),
        this.P = !1
    } catch (h) {
        Vp(this);
        return
    }
    a = d || "";
    d = new Map(this.headers);
    if (e)
        if (Object.getPrototypeOf(e) === Object.prototype)
            for (var f in e)
                d.set(f, e[f]);
        else if ("function" === typeof e.keys && "function" === typeof e.get) {
            f = ha(e.keys());
            for (var g = f.next(); !g.done; g = f.next())
                g = g.value,
                d.set(g, e.get(g))
        } else
            throw Error("bb`" + String(e));
    e = Array.from(d.keys()).find(function(h) {
        return "content-type" == h.toLowerCase()
    });
    f = z.FormData && a instanceof z.FormData;
    !Tc(Sp, c) || e || f || d.set("Content-Type", "application/x-www-form-urlencoded;charset=utf-8");
    c = ha(d);
    for (e = c.next(); !e.done; e = c.next())
        d = ha(e.value),
        e = d.next().value,
        d = d.next().value,
        this.g.setRequestHeader(e, d);
    this.A && (this.g.responseType = this.A);
    "withCredentials"in this.g && this.g.withCredentials !== this.F && (this.g.withCredentials = this.F);
    try {
        Wp(this),
        0 < this.D && (this.W = !1,
        this.I = kp(this.jc, this.D, this)),
        this.H = !0,
        this.g.send(a),
        this.H = !1
    } catch (h) {
        Vp(this)
    }
}
;
v.jc = function() {
    "undefined" != typeof va && this.g && (this.B = 8,
    this.dispatchEvent("timeout"),
    this.abort(8))
}
;
function Vp(a) {
    a.o = !1;
    a.g && (a.v = !0,
    a.g.abort(),
    a.v = !1);
    a.B = 5;
    Xp(a);
    Yp(a)
}
function Xp(a) {
    a.O || (a.O = !0,
    a.dispatchEvent("complete"),
    a.dispatchEvent("error"))
}
v.abort = function(a) {
    this.g && this.o && (this.o = !1,
    this.v = !0,
    this.g.abort(),
    this.v = !1,
    this.B = a || 7,
    this.dispatchEvent("complete"),
    this.dispatchEvent("abort"),
    Yp(this))
}
;
v.K = function() {
    this.g && (this.o && (this.o = !1,
    this.v = !0,
    this.g.abort(),
    this.v = !1),
    Yp(this, !0));
    Qp.ua.K.call(this)
}
;
v.Ac = function() {
    this.wa() || (this.P || this.H || this.v ? Zp(this) : this.ac())
}
;
v.ac = function() {
    Zp(this)
}
;
function Zp(a) {
    if (a.o && "undefined" != typeof va && (!a.J[1] || 4 != $p(a) || 2 != a.Ka()))
        if (a.H && 4 == $p(a))
            kp(a.Ac, 0, a);
        else if (a.dispatchEvent("readystatechange"),
        a.Ma()) {
            a.o = !1;
            try {
                a.Ua() ? (a.dispatchEvent("complete"),
                a.dispatchEvent("success")) : (a.B = 6,
                Xp(a))
            } finally {
                Yp(a)
            }
        }
}
function Yp(a, c) {
    if (a.g) {
        Wp(a);
        var d = a.g
          , e = a.J[0] ? n() : null;
        a.g = null;
        a.J = null;
        c || a.dispatchEvent("ready");
        try {
            d.onreadystatechange = e
        } catch (f) {}
    }
}
function Wp(a) {
    a.g && a.W && (a.g.ontimeout = null);
    a.I && (z.clearTimeout(a.I),
    a.I = null)
}
v.isActive = function() {
    return !!this.g
}
;
v.Ma = function() {
    return 4 == $p(this)
}
;
v.Ua = function() {
    var a = this.Ka();
    a: switch (a) {
    case 200:
    case 201:
    case 202:
    case 204:
    case 206:
    case 304:
    case 1223:
        var c = !0;
        break a;
    default:
        c = !1
    }
    if (!c) {
        if (a = 0 === a)
            a = ji(String(this.S))[1] || null,
            !a && z.self && z.self.location && (a = z.self.location.protocol.slice(0, -1)),
            a = !Rp.test(a ? a.toLowerCase() : "");
        c = a
    }
    return c
}
;
function $p(a) {
    return a.g ? a.g.readyState : 0
}
v.Ka = function() {
    try {
        return 2 < $p(this) ? this.g.status : -1
    } catch (a) {
        return -1
    }
}
;
function aq(a) {
    try {
        return a.g ? a.g.responseText : ""
    } catch (c) {
        return ""
    }
}
function bq(a) {
    try {
        if (!a.g)
            return null;
        if ("response"in a.g)
            return a.g.response;
        switch (a.A) {
        case "":
        case "text":
            return a.g.responseText;
        case "arraybuffer":
            if ("mozResponseArrayBuffer"in a.g)
                return a.g.mozResponseArrayBuffer
        }
        return null
    } catch (c) {
        return null
    }
}
pg(function(a) {
    Qp.prototype.ac = a(Qp.prototype.ac)
});
function cq(a, c, d) {
    Y.call(this);
    this.A = c || null;
    this.v = {};
    this.B = dq;
    this.F = a;
    if (!d) {
        this.g = null;
        this.g = new Dp(A(this.o, this));
        Kp(this.g, "setTimeout");
        Kp(this.g, "setInterval");
        a = this.g;
        c = z.window || z.globalThis;
        d = ["requestAnimationFrame", "mozRequestAnimationFrame", "webkitAnimationFrame", "msRequestAnimationFrame"];
        for (var e = 0; e < d.length; e++) {
            var f = d[e];
            d[e]in c && Kp(a, f)
        }
        a = this.g;
        og = !0;
        c = A(a.g, a);
        for (d = 0; d < mg.length; d++)
            mg[d](c);
        ng.push(a)
    }
}
Ka(cq, Y);
function eq(a, c) {
    Io.call(this, "a");
    this.error = a;
    this.Na = c
}
Ka(eq, Io);
function fq(a, c) {
    return new cq(a,c,void 0)
}
function dq(a, c, d, e) {
    if (e instanceof Map) {
        var f = {};
        e = ha(e);
        for (var g = e.next(); !g.done; g = e.next()) {
            var h = ha(g.value);
            g = h.next().value;
            h = h.next().value;
            f[g] = h
        }
    } else
        f = e;
    Up(a, null, c, d, f)
}
function gq(a, c) {
    a.B = c
}
cq.prototype.o = function(a, c) {
    a = a.error || a;
    c = c ? zg(c) : {};
    a instanceof Error && Bg(c, ke(a));
    var d = Ai(a);
    if (this.A)
        try {
            this.A(d, c)
        } catch (m) {}
    var e = d.message.substring(0, 1900);
    if (!(a instanceof tb) || a.g) {
        var f = d.fileName
          , g = d.lineNumber;
        a = d.stack;
        try {
            var h = ri(this.F, "script", f, "error", e, "line", g);
            yg(this.v) || (h = si(h, this.v));
            e = {};
            e.trace = a;
            if (c)
                for (var k in c)
                    e["context." + k] = c[k];
            var l = qi(e);
            this.B(h, "POST", l, this.D)
        } catch (m) {}
    }
    try {
        this.dispatchEvent(new eq(d,c))
    } catch (m) {}
}
;
cq.prototype.K = function() {
    Ji(this.g);
    cq.ua.K.call(this)
}
;
function hq(a) {
    this.g = a || ""
}
function iq(a) {
    return 10 > a ? "0" + a : String(a)
}
function jq(a) {
    this.g = a || ""
}
Ka(jq, hq);
function kq(a) {
    a = void 0 === a ? new lq : a;
    Y.call(this);
    var c = this;
    this.M = {};
    this.g = null;
    this.o = {};
    this.I = new np(this);
    this.Fa = a.A;
    this.oa = a.D;
    this.Ea = a.v;
    this.D = new Do;
    var d = a.g ? a.g.create(this, void 0) : null
      , e = new Qp
      , f = a.Ba;
    mq(this, f);
    this.A = d || new yp(e,f,void 0);
    R(this, this.A);
    this.B = T(f, "docs-sup") + T(f, "docs-jepp") + "/jserror";
    if (d = T(f, "jobset"))
        this.B = ri(this.B, "jobset", d);
    if (d = T(f, "docs-ci"))
        this.B = ri(this.B, "id", d);
    nq(this);
    Bh = function(g) {
        return oq(g, "promise rejection")
    }
    ;
    Ih = function(g) {
        oq(g, "deferred error")
    }
    ;
    a.o && (d = new Dp(function(g) {
        var h = {};
        h = (h.isUnhandledRejection = "true",
        h);
        c.info(g, h)
    }
    ),
    Jp(d),
    R(this, d));
    this.J = a.j;
    this.F = !1;
    this.H = !0;
    this.v = !1;
    this.P = T(f, "docs-jern");
    this.W = a.B;
    this.S = a.C.concat(Object.values(kj));
    this.fa = S(f, "docs-eett")
}
y(kq, Y);
function nq(a) {
    var c = void 0 === c ? !1 : c;
    if (pq)
        throw Error("cb");
    pq = !0;
    a.g = fq(a.B, function(e, f) {
        var g = a.F;
        try {
            a.O(e, f)
        } catch (k) {
            throw g && !a.J && (a.H = !1),
            a.F = !0,
            f.provideLogDataError = k.message,
            f.severity || (f.severity = "fatal"),
            Gi(k);
        } finally {
            if (f["severity-unprefixed"] = f.severity || "fatal",
            f.severity = "" + f["severity-unprefixed"],
            !a.W)
                for (var h in f)
                    "number" === typeof f[h] || f[h]instanceof Number || "boolean" === typeof f[h] || f[h]instanceof Boolean || a.S.includes(h) || h in f && delete f[h]
        }
    });
    var d = {};
    a.oa && (d["X-No-Abort"] = "1");
    a.g.D = d;
    gq(a.g, function(e, f, g, h) {
        a.H && a.A.send(e, f, g, h)
    });
    qp(a.I, a.g, "a", function(e) {
        e.Na.severity = e.Na["severity-unprefixed"] || e.Na.severity;
        var f = e.Na.severity;
        (f = "fatal" == f || "postmortem" == f) && !a.Ea && (!a.Fa || (void 0 === c ? 0 : c) ? a.D.notify(void 0, a, e.Na) : a.D.notify(e, a, e.Na));
        a.dispatchEvent(new qq(f ? "b" : "c",e.error,e.Na))
    })
}
function mq(a, c) {
    c = new Bp(c);
    var d = c.g, e;
    for (e in d) {
        var f = d[e];
        f && (a.o["expflag-" + e] = f.toString())
    }
    a.o.experimentIds = c.j.join(",")
}
function rq(a, c) {
    a.D = c
}
function sq(a, c, d, e) {
    a.v = e || !1;
    if (!a.g) {
        if (c instanceof Rh)
            throw c.N;
        throw Gi(c);
    }
    a.g.o(c, tq("fatal", d))
}
function uq(a, c, d, e) {
    a.v = e || !1;
    a.g && a.g.o(c, tq("warning", d))
}
kq.prototype.info = function(a, c, d) {
    this.v = d || !1;
    this.g && this.g.o(a, tq("incident", c))
}
;
kq.prototype.log = function(a, c, d) {
    this.v = !!d;
    this.g && this.g.o(a, tq("incident", c))
}
;
function oq(a, c) {
    if (null != a) {
        if (a && "object" === typeof a && "error" === a.type) {
            var d = a.error;
            a = JSON.stringify({
                error: d && d.message ? d.message : "Missing error cause.",
                stack: d && d.stack ? d.stack : "Missing error cause.",
                message: a.message,
                filename: a.filename,
                lineno: a.lineno,
                colno: a.colno,
                type: a.type
            });
            c = Error("db`" + c + "`" + a)
        } else
            c = "string" === typeof a ? Error("eb`" + c + "`" + a) : null == a ? Error("fb`" + c) : a;
        kc(c)
    }
}
function vq(a, c, d, e) {
    return function() {
        a: {
            var f = !!e
              , g = qa.apply(0, arguments);
            if (a.g) {
                try {
                    var h = c.apply(d, g);
                    break a
                } catch (k) {
                    if (sq(a, k),
                    f)
                        throw Gi(k);
                }
                h = void 0
            } else
                h = c.apply(d, g)
        }
        return h
    }
}
function wq(a, c) {
    a.g && c.then(void 0, function(d) {
        sq(a, d instanceof Error ? d : Error(d))
    });
    return c
}
function tq(a, c) {
    c = c ? zg(c) : {};
    c.severity = a;
    return c
}
kq.prototype.O = function(a, c) {
    for (var d in this.M)
        try {
            c[d] = this.M[d](a)
        } catch (h) {}
    Bg(c, this.o);
    if (0 < (Oi(),
    0)) {
        var e = new jq
          , f = "";
        Ni(function(h) {
            var k = f
              , l = [];
            l.push(e.g, " ");
            var m = l.push
              , p = new Date(h.Wc());
            m.call(l, "[", iq(p.getFullYear() - 2E3) + iq(p.getMonth() + 1) + iq(p.getDate()) + " " + iq(p.getHours()) + ":" + iq(p.getMinutes()) + ":" + iq(p.getSeconds()) + "." + iq(Math.floor(p.getMilliseconds() / 10)), "] ");
            m = l.push;
            p = null.get();
            p = (h.Wc() - p) / 1E3;
            var r = p.toFixed(3)
              , u = 0;
            if (1 > p)
                u = 2;
            else
                for (; 100 > p; )
                    u++,
                    p *= 10;
            for (; 0 < u--; )
                r = " " + r;
            m.call(l, "[", r, "s] ");
            l.push("[", h.be(), "] ");
            l.push(h.Ld());
            l.push("\n");
            f = k + l.join("")
        });
        c.clientLog = f
    }
    d = c.severity || "fatal";
    this.fa && (a.message.includes("Trusted Type") || a.message.includes("TrustedHTML") || a.message.includes("TrustedScript")) && (d = "warning");
    this.P && (c.reportName = this.P + "_" + d);
    c.isArrayPrototypeIntact = Cp().toString();
    var g = a.stack || "";
    if (0 == g.trim().length || "Not available" == g)
        c["stacklessError-reportingStack"] = Fi(kq.prototype.O),
        [a.message].concat(ja(Object.keys(c)), ja(Object.values(c))).some(function(h) {
            return h.includes("<eye3")
        }) || (c.eye3Hint = "<eye3-stackless title='Stackless JS Error - " + a.name + "'/>");
    this.F && !this.J ? (this.H = this.v,
    "fatal" == d ? d = "postmortem" : "incident" == d && (d = "warningafterdeath")) : "fatal" == d && (this.F = !0);
    this.v = !1;
    c.severity = d
}
;
kq.prototype.K = function() {
    pq = !1;
    Ki(this.I, this.g, this.A);
    Y.prototype.K.call(this)
}
;
var pq = !1;
function qq(a, c) {
    Io.call(this, a);
    this.error = c
}
y(qq, Io);
function lq() {
    this.Ba = void 0;
    this.v = this.A = !1;
    this.g = void 0;
    this.D = this.j = !1;
    this.B = !0;
    this.C = [];
    this.o = !1
}
;function xq(a) {
    var c = a.target.error
      , d = c && c.name;
    c = c && c.message || a.target.webkitErrorMessage;
    a.target.docs_internalAbort && (c = "Internal abort: " + c);
    return d + " (" + c + ")"
}
function yq(a) {
    for (var c = [], d = 0; d < a.length; d++)
        c.push(a.item(d));
    return c.toString()
}
;function zq(a, c, d, e, f, g) {
    Ch.call(this, f, g);
    this.F = a;
    this.L = [];
    this.J = !!c;
    this.W = !!d;
    this.V = !!e;
    for (c = this.O = 0; c < a.length; c++)
        Kh(a[c], A(this.M, this, c, !0), A(this.M, this, c, !1));
    0 != a.length || this.J || this.qa(this.L)
}
Ka(zq, Ch);
zq.prototype.M = function(a, c, d) {
    this.O++;
    this.L[a] = [c, d];
    this.g || (this.J && c ? this.qa([a, d]) : this.W && !c ? this.yb(d) : this.O == this.F.length && this.qa(this.L));
    this.V && !c && (d = null);
    return d
}
;
zq.prototype.yb = function(a) {
    zq.ua.yb.call(this, a);
    for (a = 0; a < this.F.length; a++)
        this.F[a].cancel()
}
;
function Aq(a, c, d, e, f, g, h) {
    vp.call(this, e, f, h);
    this.F = c;
    this.v = c + "-f";
    this.o = c + "-n";
    this.A = d;
    this.P = a;
    this.g = null;
    this.W = g || z.indexedDB || z.webkitIndexedDB;
    Bq(this)
}
y(Aq, vp);
function Bq(a) {
    var c = a.W.open("DocsErrors", 1);
    c.onsuccess = function(d) {
        return void Cq(a, d)
    }
    ;
    c.onupgradeneeded = function(d) {
        d.target.transaction.db.createObjectStore("Errors", {
            keyPath: "key"
        })
    }
    ;
    c.onerror = function(d) {
        Dq(a);
        uq(a.P, Error("hb`" + xq(d)))
    }
    ;
    c.onblocked = function(d) {
        Dq(a);
        uq(a.P, Error("gb`" + xq(d)))
    }
}
function Cq(a, c) {
    var d = c.target.result
      , e = Eq(d, "readwrite");
    Jh(new zq([Fq(a.v, e), Fq(a.o, e)]), function(f) {
        null == f[0][1] || null == f[1][1] ? (f = e.objectStore("Errors"),
        f.put({
            key: this.v,
            value: "1"
        }),
        f.put({
            key: this.o,
            value: "1"
        }),
        e.oncomplete = A(this.rc, this, d)) : this.rc(d)
    }, a)
}
v = Aq.prototype;
v.rc = function(a) {
    this.g = a;
    this.B()
}
;
v.zb = function(a) {
    if (!this.g)
        return this.A.zb(a);
    var c = Eq(this.g, "readwrite")
      , d = new Ch;
    Jh(Fq(this.o, c), function(e) {
        if (e) {
            var f = c.objectStore("Errors");
            f.put({
                key: this.o,
                value: String(e + 1)
            });
            f.put({
                key: this.F + "-e-" + e,
                value: JSON.stringify(a)
            });
            c.oncomplete = A(d.qa, d)
        } else
            d.qa()
    }, this);
    return d
}
;
v.Oa = function() {
    if (!this.g)
        return this.A.Oa();
    var a = Eq(this.g, "readwrite")
      , c = new Ch;
    Jh(new zq([Fq(this.v, a), Fq(this.o, a)]), function(d) {
        var e = d[0][1];
        d = d[1][1];
        if (!e || d <= e)
            c.qa();
        else {
            var f = a.objectStore("Errors");
            f["delete"](this.F + "-e-" + e);
            e++;
            f.put({
                key: this.v,
                value: String(e)
            });
            Jh(Gq(this, a), function(g) {
                0 == g && (f.put({
                    key: this.v,
                    value: "1"
                }),
                f.put({
                    key: this.o,
                    value: "1"
                }));
                a.oncomplete = A(c.qa, c)
            }, this)
        }
    }, this);
    return c
}
;
v.cb = function() {
    if (!this.g)
        return this.A.cb();
    var a = Eq(this.g, "readonly");
    return Jh(new zq([Fq(this.v, a), Fq(this.o, a)]), function(c) {
        var d = c[0][1];
        return !d || 1 > c[1][1] - d ? null : Jh(Hq(this.F + "-e-" + d, a), function(e) {
            return e && (e = JSON.parse(e)) ? e : Jh(this.Oa(), this.cb, this)
        }, this)
    }, this)
}
;
v.fb = function() {
    if (!this.g)
        return this.A.fb();
    var a = Eq(this.g, "readonly");
    return Gq(this, a)
}
;
function Dq(a) {
    a.g && (a.g.close(),
    a.g = null)
}
function Gq(a, c) {
    return Jh(new zq([Fq(a.v, c), Fq(a.o, c)]), function(d) {
        return d[1][1] - d[0][1]
    })
}
function Fq(a, c) {
    return Jh(Hq(a, c), function(d) {
        d = parseInt(d, 10);
        return 0 > d || isNaN(d) ? null : d
    })
}
function Hq(a, c) {
    c = c.objectStore("Errors");
    var d = new Ch;
    c.get(a).onsuccess = function(e) {
        e.target.result ? d.qa(e.target.result.value) : d.qa(null)
    }
    ;
    return d
}
function Eq(a, c) {
    var d = ["Errors"];
    try {
        return a.transaction(d, c)
    } catch (e) {
        throw c = yq(a.objectStoreNames),
        Gi(e, {
            databaseName: a.name,
            databaseObjectStores: c,
            databaseVersion: a.version.toString(),
            transactionObjectStores: d.toString()
        });
    }
}
v.K = function() {
    Dq(this);
    vp.prototype.K.call(this)
}
;
function Iq() {
    try {
        var a = z.localStorage;
        if (a && (ed || fd) && (a.setItem("test", "test"),
        "test" == a.getItem("test") && (a.removeItem("test"),
        null == a.getItem("test"))))
            return !0
    } catch (c) {}
    return !1
}
;function Jq() {
    Q.call(this);
    this.g = {}
}
y(Jq, Q);
Jq.prototype.Ga = function(a, c, d) {
    var e = this;
    if ("function" === typeof a)
        d && (a = A(a, d));
    else if (a && "function" == typeof a.handleEvent)
        a = A(a.handleEvent, a);
    else
        throw Error("Ua");
    var f = new Kq;
    c = kp(function() {
        var g = a
          , h = f.R();
        null !== h && delete e.g[h];
        g()
    }, c);
    this.g[c] = !0;
    return f.g = c
}
;
Jq.prototype.clear = function(a) {
    null !== a && delete this.g[a];
    z.clearTimeout(a)
}
;
Jq.prototype.K = function() {
    for (var a in this.g)
        this.clear(Number(a));
    Q.prototype.K.call(this)
}
;
function Kq() {
    this.g = null
}
Kq.prototype.R = q("g");
function Lq(a, c, d, e, f) {
    vp.call(this, a, d, e, f);
    this.F = c;
    this.A = c + "-v";
    this.v = c + "-f";
    this.o = c + "-n";
    this.g = z.localStorage;
    Iq();
    a = Mq(this, this.A);
    if (!a || 1 > a)
        this.g.setItem(this.A, "1"),
        this.g.setItem(this.v, "1"),
        this.g.setItem(this.o, "1");
    this.B();
    this.P = new Jq;
    R(this, this.P);
    this.P.Ga(this.Lc, 3E4, this)
}
y(Lq, vp);
v = Lq.prototype;
v.zb = function(a) {
    var c = Mq(this, this.o);
    if (!c || 1 != Mq(this, this.A))
        return Qh();
    try {
        this.g.setItem(this.o, String(c + 1)),
        this.g.setItem(this.F + "-e-" + c, JSON.stringify(a))
    } catch (d) {}
    return Qh()
}
;
v.Oa = function() {
    var a = Mq(this, this.v);
    if (!a || 1 != Mq(this, this.A))
        return Qh();
    this.g.removeItem(this.F + "-e-" + a);
    a++;
    this.g.setItem(this.v, String(a));
    return Jh(this.fb(), function(c) {
        0 == c && (this.g.setItem(this.v, "1"),
        this.g.setItem(this.o, "1"))
    }, this)
}
;
v.cb = function() {
    var a = Mq(this, this.v);
    return a && 1 == Mq(this, this.A) ? Jh(this.fb(), function(c) {
        if (1 > c)
            return null;
        try {
            var d = this.g.getItem(this.F + "-e-" + a);
            if (d) {
                var e = JSON.parse(d);
                if (e)
                    return e
            }
        } catch (f) {}
        return Jh(this.Oa(), this.cb, this)
    }, this) : Qh(null)
}
;
v.fb = function() {
    return Qh(Mq(this, this.o) - Mq(this, this.v))
}
;
function Mq(a, c) {
    return (a = a.g.getItem(c)) ? Nq(a) : null
}
function Nq(a) {
    a = parseInt(a, 10);
    return 0 > a || isNaN(a) ? null : a
}
v.Lc = function() {
    if (Mq(this, this.o) && 1 == Mq(this, this.A))
        for (var a = this.F + "-e-", c = 0, d = this.g.length; c < d; ++c) {
            var e = this.g.key(c);
            if (e && lc(e, a)) {
                var f = Nq(e.substring(a.length))
                  , g = Mq(this, this.o);
                g && f && f >= g && this.g.removeItem(e)
            }
        }
}
;
v.K = function() {
    vp.prototype.K.call(this)
}
;
function Oq(a, c) {
    this.g = a;
    this.j = c
}
Oq.prototype.create = function(a, c) {
    return Iq() ? new Lq(new Qp,this.g,this.j,c) : null
}
;
function Pq() {
    var a = Qq;
    this.j = Rq;
    this.g = a
}
Pq.prototype.create = function(a, c) {
    var d = (new Oq(this.j,this.g)).create(a, c) || new yp(new Qp,this.g,c);
    return ed && (z.indexedDB || z.webkitIndexedDB) ? new Aq(a,this.j,d,new Qp,this.g,void 0,c) : d
}
;
function Sq(a, c) {
    this.j = a;
    this.g = c
}
Sq.prototype.notify = function(a, c, d) {
    null != this.g && this.g.j() && this.g.g() || this.j.notify(a, c, d)
}
;
function Tq(a) {
    this.G = G(a)
}
y(Tq, O);
function Uq(a) {
    switch (a) {
    case "2g":
        return 2;
    case "3g":
        return 3;
    case "4g":
        return 4;
    case "slow-2g":
        return 1;
    default:
        return 5
    }
}
;function Vq(a) {
    tb.call(this);
    this.j = a
}
y(Vq, tb);
function Wq(a, c) {
    this.A = a;
    this.g = this.v = this.j = 0;
    this.o = void 0 === c ? 3E4 : c;
    for (a = Xq; a < this.o; )
        a *= 2;
    this.C = a
}
function Yq(a, c) {
    if (S(a.A, "docs-irbfes"))
        if (0 !== a.g && 2 !== c)
            if (1 === c)
                c = 4 > a.j ? Xq : a.g < a.o ? 2 * a.g : a.C;
            else if (3 === c)
                c = a.g < Math.max(a.o, 18E4) ? 2 * a.g : a.g;
            else
                throw Error("ib");
        else
            c = Xq;
    else {
        var d = 2 != c && !(4 > a.j);
        c = Xq;
        d && 0 != a.g && (c = a.g < a.o ? 2 * a.g : a.g)
    }
    a.g = c;
    return Math.max(0, c - (Date.now() - a.v))
}
function Zq(a) {
    var c = Date.now();
    a.j++;
    a.v = c
}
var Xq = 5E3 * (.75 + .5 * Math.random());
function $q(a) {
    this.G = G(a)
}
y($q, O);
function ar(a) {
    this.G = G(a)
}
y(ar, O);
function br(a) {
    this.G = G(a, 4)
}
y(br, O);
function cr(a) {
    this.G = G(a, 35)
}
y(cr, O);
function dr(a, c) {
    return M(a, 8, c)
}
cr.ia = [3, 20, 27];
function er() {
    var a = fr
      , c = Fj(a, "docs-cclt");
    a = S(a, "docs-eoiua") && T(a, "gaia_session_id") ? T(a, "gaia_session_id") : "0";
    a = new gr(c,a);
    a.j = !0;
    a.g = !0;
    c = new hr({
        gb: a.gb,
        pb: a.pb ? a.pb : Vn,
        Va: a.Va,
        sd: "https://play.google.com/log?format=json&hasfast=true",
        Ta: a.j,
        mb: a.g,
        sc: a.o,
        ib: a.ib,
        nc: a.nc,
        pa: a.pa ? a.pa : void 0
    });
    R(a, c);
    a.jb && (c.jb = a.jb);
    ir(c.v);
    a.pa.wb && a.pa.wb(a.gb);
    a.pa.od && a.pa.od(c);
    a = fr;
    var d = jr;
    this.j = c;
    this.o = a;
    this.v = d || null;
    this.j.M = 1;
    this.j.Mb = 2E4
}
er.prototype.g = function(a) {
    var c = this;
    if (S(this.o, "docs-ecir"))
        return kr(this, a, new Wq(this.o));
    a = dr(new cr, a.Z());
    lr(this.j, a);
    return new dh(function(d, e) {
        mr(c, d, e)
    }
    )
}
;
function kr(a, c, d) {
    var e = dr(new cr, c.Z());
    lr(a.j, e);
    return (new dh(function(f, g) {
        Zq(d);
        mr(a, f, g)
    }
    )).Aa(function(f) {
        if ("number" === typeof f && (500 <= f && 600 > f || 401 == f || 0 == f) && 4 > d.j)
            return f = Yq(d, 0 === f ? 1 : 3),
            lp(f).then(function() {
                return kr(a, c, d)
            });
        throw nr(f);
    })
}
function mr(a, c, d) {
    a.j.flush(c, function(e, f) {
        var g = Error("jb`" + e + "`" + f);
        a.v && S(a.o, "docs-ecer") && uq(a.v, g, {
            failureType: e,
            errorCode: "" + f
        });
        e = S(a.o, "docs-ecir") ? f : nr(f);
        d(e)
    })
}
function nr(a) {
    return "number" === typeof a ? new Vq(!(500 <= a && 600 > a || 401 == a || 0 == a)) : a
}
;function or() {
    var a = pr;
    this.g = qr;
    this.j = a
}
or.prototype.sa = q("g");
function rr(a, c, d) {
    Io.call(this, a);
    this.j = this.cause = null;
    this.C = c;
    this.g = d
}
y(rr, Io);
rr.prototype.getType = q("type");
function sr() {
    var a = tr
      , c = fr
      , d = !0;
    d = void 0 === d ? !1 : d;
    this.o = a;
    this.j = c;
    this.v = T(this.j, "docs-liap") || "/logImpressions";
    this.A = d
}
sr.prototype.g = function(a, c) {
    S(this.j, "docs-ecssl") && ur(a, a.Z());
    return new dh(function(d, e) {
        var f = S(this.j, "docs-daflia")
          , g = T(this.j, "docs-sup")
          , h = vr(this.o, this.v);
        f && (h.o = g);
        wr(h, c ? ["id", c] : []);
        f = xr;
        h.B = 2;
        yr(zr(f(h, {
            impressionBatch: Le(a, Me(a.G), !0)
        }), d), function(k) {
            k = "d" == k.getType() && (!k.j || "d" == k.j);
            e(new Vq(k))
        }).C = !0;
        this.A && h.setTimeout(5E3);
        Ar(h)
    }
    ,this)
}
;
function Br() {
    var a = Cr
      , c = [new er];
    this.o = a;
    this.j = c
}
Br.prototype.g = function(a, c) {
    for (var d = 0; d < this.j.length; d++)
        this.j[d].g(a, c).Aa(n());
    return this.o.g(a, c)
}
;
function Dr() {
    this.j = new Er
}
Dr.prototype.g = function(a) {
    return this.j.g(a)
}
;
var Fr = [0, ag, [0, bg, $f], bg, cg];
function Gr(a) {
    this.G = G(a)
}
y(Gr, O);
function Hr(a) {
    this.G = G(a)
}
y(Hr, O);
Hr.ia = [3, 42];
function Ir(a) {
    this.G = G(a)
}
y(Ir, O);
var Jr = function(a, c) {
    return function(d, e) {
        a: {
            if (Ff.length) {
                var f = Ff.pop();
                Bf(f, e);
                f.g.init(d, void 0, void 0, e);
                d = f
            } else
                d = new Af(d,e);
            try {
                var g = new a
                  , h = g.G;
                If(c)(h, d);
                var k = g;
                break a
            } finally {
                d.g.clear(),
                d.v = -1,
                d.j = -1,
                100 > Ff.length && Ff.push(d)
            }
            k = void 0
        }
        return k
    }
}(Ir, [0, Fr]);
function Kr(a) {
    this.G = G(a)
}
y(Kr, O);
function Lr(a) {
    this.G = G(a)
}
y(Lr, O);
function Mr(a) {
    this.G = G(a)
}
y(Mr, O);
function Nr(a) {
    this.G = G(a)
}
y(Nr, O);
Nr.ia = [3];
function Or(a) {
    this.G = G(a)
}
y(Or, O);
function Pr(a) {
    this.G = G(a)
}
y(Pr, O);
Pr.ia = [2];
function Qr(a) {
    this.G = G(a)
}
y(Qr, O);
Qr.ia = [2, 27, 36];
function Rr(a) {
    this.G = G(a)
}
y(Rr, O);
Rr.ia = [1];
function Sr(a) {
    this.G = G(a)
}
y(Sr, O);
function Tr(a) {
    this.G = G(a)
}
y(Tr, O);
Tr.ia = [4, 5];
function Ur(a) {
    this.G = G(a)
}
y(Ur, O);
function Vr(a) {
    this.G = G(a)
}
y(Vr, O);
function Wr(a) {
    this.G = G(a)
}
y(Wr, O);
function Xr(a) {
    this.G = G(a)
}
y(Xr, O);
function Yr(a, c) {
    return M(a, 6, c)
}
function Zr(a, c) {
    return J(a, 13, c)
}
;function $r(a) {
    this.G = G(a)
}
y($r, O);
function as(a) {
    this.G = G(a)
}
y(as, O);
function bs(a) {
    this.G = G(a)
}
y(bs, O);
function cs(a) {
    return H(a, Xr, 1)
}
;function ds(a) {
    this.G = G(a)
}
y(ds, O);
function es(a) {
    return H(a, bs, 50)
}
;function Er() {
    var a = new fs;
    this.o = gs;
    this.j = a
}
Er.prototype.g = function(a) {
    return this.o.g(a, null).Aa(function(c) {
        if (!(c instanceof Vq && c.j)) {
            c = ef(a, hs, 1);
            c = ha(c);
            for (var d = c.next(); !d.done; d = c.next()) {
                d = d.value;
                if (!Ve(d, ds, 5)) {
                    var e = d
                      , f = new ds;
                    I(e, ds, 5, f)
                }
                Ve(H(d, ds, 5), Qr, 34) || (e = H(d, ds, 5),
                f = new Qr,
                I(e, Qr, 34, f));
                J(H(H(d, ds, 5), Qr, 34), 26, !0)
            }
            return is(this, a)
        }
    }, this)
}
;
function is(a, c) {
    return new dh(function(d, e) {
        a.j.g(c, d, e)
    }
    )
}
;function js(a) {
    var c = void 0 === c ? !1 : c;
    this.g = new bo(a);
    this.o = c;
    c = this.g.g;
    var d = c.get("usp")
      , e = c.get("urp")
      , f = c.get("cros_files", "")
      , g = ks(d, this.o);
    a = c.get("dl");
    var h = Hn(this.g.o)
      , k = c.get("rtpof", "")
      , l = c.get("pli");
    c = new Nr;
    var m = new Mr;
    I(c, Mr, 1, m);
    var p = new Lr;
    h = J(p, 3, h);
    I(m, Lr, 1, h);
    d && M(h, 1, d);
    e && M(h, 2, e);
    null !== g && N(m, 5, g);
    "1" === l && J(h, 6, !0);
    J(h, 7, "true" == f);
    J(h, 4, "true" == k);
    d = null;
    if (a)
        try {
            d = Jr(id(a))
        } catch (r) {
            d = null
        }
    d && (a = new Kr,
    I(c, Kr, 2, a),
    I(a, Ir, 1, d));
    this.j = c
}
function ks(a, c) {
    var d = z;
    d = d.window || d;
    if (d.parent == d && null == d.frameElement)
        return null;
    if (c)
        return 1;
    if (a)
        switch (a) {
        case "mole":
            return 2
        }
    return 3
}
;function ls(a, c, d) {
    this.v = a;
    this.o = c;
    this.j = d
}
ls.prototype.g = function(a, c, d) {
    a = new pl(null,this.o,Date.now(),a.toJSON(),!0,this.j);
    this.v.write([a], c, d)
}
;
function fs() {
    var a = ms
      , c = ns;
    this.o = os;
    this.v = a;
    this.j = c
}
fs.prototype.g = function(a, c, d) {
    var e = this;
    ps(this.o).then(function(f) {
        f ? (new ls(f.g,e.v,e.j)).g(a, c, d) : c()
    })
}
;
function qs(a) {
    this.G = G(a, 1)
}
y(qs, O);
function rs(a) {
    this.G = G(a, 1)
}
y(rs, O);
function ss(a) {
    this.G = G(a)
}
y(ss, O);
ss.ia = [1];
var ts = new uf(113007630,ss);
function us(a) {
    this.G = G(a)
}
y(us, O);
us.ia = [3];
var vs = new uf(112987886,us);
function ws(a, c) {
    Q.call(this);
    var d = this;
    this.j = c;
    this.g = new Uj;
    R(this, this.g);
    Vj(this.g, a.v, function(e) {
        var f = [];
        e = e.g;
        for (var g = 0; g < e.length; g++) {
            var h = e[g];
            switch (h.g.A) {
            case "document":
                var k = new us;
                M(k, 1, h.g.R());
                a: {
                    var l = h.j;
                    switch (l) {
                    case "new":
                        l = 1;
                        break a;
                    case "update":
                        l = 2;
                        break a;
                    case "delete":
                        l = 3;
                        break a;
                    default:
                        throw Error("lb`" + l);
                    }
                }
                N(k, 2, l);
                l = [];
                h = h.o;
                xg(h, "ip") && l.push(1);
                xg(h, "pendingQueueState") && l.push(6);
                xg(h, "lastModifiedClientTimestamp") && l.push(2);
                (xg(h, "lsst") || xg(h, "lsft") || xg(h, "lss")) && l.push(3);
                xg(h, "pendingCreation") && l.push(4);
                xg(h, "title") && l.push(5);
                cf(k, 3, l, pe);
                if (!(h = 2 != kf(k, 2))) {
                    h = void 0;
                    l = k.G;
                    var m = Ld(l)
                      , p = 2 & m ? 1 : 2;
                    h = !!h;
                    var r = Ze(l, m, 3)
                      , u = Kd(r);
                    if (!(4 & u)) {
                        if (4 & u || Object.isFrozen(r))
                            r = Dd(r),
                            u = af(u, m, h),
                            m = Ue(l, m, 3, r);
                        for (var w = 0, F = 0; w < r.length; w++) {
                            var L = qe(r[w]);
                            null != L && (r[F++] = L)
                        }
                        F < w && (r.length = F);
                        u = $e(u, m, h);
                        u = Jd(u, 20, !0);
                        u = Jd(u, 4096, !1);
                        u = Jd(u, 8192, !1);
                        Md(r, u);
                        2 & u && Object.freeze(r)
                    }
                    bf(u) || (w = u,
                    (F = 1 === p) ? u = Jd(u, 2, !0) : h || (u = Jd(u, 32, !1)),
                    u !== w && Md(r, u),
                    F && Object.freeze(r));
                    2 === p && bf(u) && (r = Dd(r),
                    u = af(u, m, h),
                    Md(r, u),
                    Ue(l, m, 3, r));
                    h = r;
                    h = h.length
                }
                h && (h = new rs,
                tf(h, vs, k),
                f.push(h))
            }
        }
        f.length && (e = new ss,
        ff(e, rs, 1, f),
        f = new qs,
        tf(f, ts, e),
        d.j.g(f))
    })
}
y(ws, Q);
function xs() {}
function ys(a, c, d, e, f, g) {
    f = void 0 === f ? !1 : f;
    g = void 0 === g ? !1 : g;
    c = void 0 !== c ? zs(c, d) : null;
    f = f ? "prev" : "next";
    if (e)
        return a = As(a, e),
        g ? (g = (g = void 0 !== c) && void 0 !== f ? a.g.openKeyCursor(c, f) : g ? a.g.openKeyCursor(c) : a.g.openKeyCursor(),
        c = new Bs(g,a.j,a.g.name + ".openKeyCursor(" + (c ? c.lower + ", " + c.upper : c) + ", " + f + ")",a.A,a.v,a.o)) : (g = (g = void 0 !== c) && void 0 !== f ? a.g.openCursor(c, f) : g ? a.g.openCursor(c) : a.g.openCursor(),
        c = new Bs(g,a.j,a.g.name + ".openCursor(" + (c ? c.lower + ", " + c.upper : c) + ", " + f + ")",a.A,a.v,a.o)),
        c;
    g = (g = void 0 !== c) && void 0 !== f ? a.g.openCursor(c, f) : g ? a.g.openCursor(c) : a.g.openCursor();
    return new Bs(g,a.j,a.g.name + ".openCursor(" + (c ? c.lower + ", " + c.upper : c) + ", " + f + ")",a.A,a.v,a.o)
}
function Cs(a, c, d, e) {
    c = zs(c, d);
    a = Ds(a, c);
    e && Es(a, e)
}
function Fs(a, c, d) {
    var e = void 0 === e ? !1 : e;
    var f = void 0 === f ? !1 : f;
    var g = void 0 === g ? !1 : g;
    var h = Z(a, "Documents")
      , k = [];
    Es(ys(h, void 0, void 0, void 0, e, f), function(l) {
        if (l = l.target.result) {
            var m = void 0 !== l.value ? l.value : l.key;
            (m = c(m)) && k.push(m);
            l["continue"]()
        } else
            g && Gs(a),
            d && d(k)
    })
}
function Hs(a, c) {
    return function(d) {
        d.stopPropagation();
        c(new Qk(1,a + " (" + xq(d) + ")",d))
    }
}
function zs(a, c) {
    return void 0 === c || a == c ? Is.only(a) : Is.bound(a, c, void 0, void 0)
}
var Is = z.IDBKeyRange || z.webkitIDBKeyRange;
function Js(a) {
    Q.call(this);
    this.g = a
}
y(Js, Q);
function Ks(a, c, d, e, f, g) {
    var h = {};
    h.dcKey = [a, c, d, e];
    h.t = f;
    g && (h.c = g);
    return new Js(h)
}
Js.prototype.K = function() {
    delete this.g;
    Q.prototype.K.call(this)
}
;
function Ls(a, c, d, e, f, g) {
    Ok.call(this, a, e, g);
    this.jd = c;
    this.Fc = d
}
y(Ls, Ok);
Ls.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "append-commands":
        Ms(this, a, c);
        break;
    default:
        throw Error("mb`" + a.getType());
    }
}
;
function Ms(a, c, d) {
    if (c.A) {
        var e = Z(d, "DocumentCommands");
        Ns(c.j, e, function() {
            return Os(a, c, d)
        })
    } else
        Os(a, c, d)
}
function Ns(a, c, d) {
    Cs(c, [a], [a, []], d)
}
function Os(a, c, d) {
    d = Z(d, "DocumentCommands");
    for (var e = c.o, f = 0; f < e.length; ++f) {
        for (var g = a, h = d, k = c.j, l = e[f], m = l.j, p = [], r = 0; r < m.length; ++r)
            p.push(g.Db.Z(m[r]));
        h.put(Ks(k, l.o, l.v, l.g, l.A, p).g)
    }
}
;function Ps(a, c, d, e) {
    Q.call(this);
    this.F = a;
    this.B = c;
    this.j = d;
    this.A = e || Date.now;
    this.v = this.g = 0;
    this.o = []
}
y(Ps, Q);
Ps.prototype.start = function() {
    if (this.v)
        throw Error("nb");
    this.v = this.A() + this.B;
    this.g = kp(this.D, this.B, this)
}
;
Ps.prototype.D = function() {
    this.g = 0;
    var a = this.A() - this.v;
    this.o.push(a);
    var c = this.j.hidden || this.j.webkitHidden || this.j.mozHidden || this.j.msHidden ? 1020 : 20;
    10 > this.o.length && a > c ? (this.v = this.A() + 1E3,
    this.g = kp(this.D, 1E3, this)) : this.F(this)
}
;
Ps.prototype.K = function() {
    this.g && z.clearTimeout(this.g)
}
;
function Bs(a, c, d, e, f, g, h, k, l, m) {
    var p = this;
    this.M = a;
    this.o = c;
    this.I = d;
    this.H = e;
    this.O = f;
    this.P = Qs(f, d);
    this.v = this.D = null;
    this.C = h || null;
    this.A = g;
    this.j = m ? rj(this.A, m) : null;
    this.F = l || 0;
    this.g = null;
    0 < this.F && (this.C || k) && (this.g = new Ps(function() {
        p.j && uj(p.A, p.j);
        p.o.info(Error("qb"), {
            documentHidden: document.hidden || document.webkitHidden,
            request: p.I,
            requestTimeoutMs: p.F,
            timeoutCallbackSet: !!p.C,
            timeoutDelays: p.g.o.concat().toString()
        });
        Ji(p.g);
        !p.H.g && p.C && (p.J(p.M),
        p.C())
    }
    ,this.F,document),
    this.g.start());
    this.M.onsuccess = vq(this.o, this.fa, this, !0);
    this.M.onerror = vq(this.o, this.S, this, !0)
}
function Es(a, c) {
    if (a.D)
        throw Error("ob");
    a.D = c
}
Bs.prototype.fa = function(a) {
    Ji(this.g);
    this.j && tj(this.A, this.j);
    var c = this.O
      , d = this.P;
    c.o++;
    delete c.g[d];
    this.H.g || this.D && this.D(a)
}
;
function Rs(a, c) {
    if (a.v)
        throw Error("pb");
    a.v = c
}
Bs.prototype.S = function(a) {
    Ji(this.g);
    this.j && uj(this.A, this.j);
    var c = this.O
      , d = this.P;
    c.j++;
    delete c.g[d];
    a.target.docs_requestContext = this.I;
    this.H.g || (c = a.target.error) && "AbortError" == c.name || this.v && this.v(a)
}
;
Bs.prototype.J = function(a) {
    a.onsuccess = n();
    a.onerror = n()
}
;
function Ss() {
    this.g = {};
    this.v = this.o = this.j = 0
}
function Qs(a, c) {
    var d = a.v++;
    a.g[d] = c;
    return d
}
;function Ts() {
    this.j = this.o = this.g = !1
}
;function Us(a) {
    try {
        var c = z.localStorage.getItem("docs-ucb")
    } catch (d) {
        return a.info(Error("sb`" + d.message)),
        "e"
    }
    switch (c) {
    case "1":
        return "t";
    case "0":
        return "f";
    default:
        return "u"
    }
}
;function Vs(a, c, d, e, f, g, h, k) {
    Bs.call(this, a, c, d, new Ts, new Ss, e, g, !0, h, k);
    this.L = this.B = null;
    this.V = f;
    a.onblocked = vq(c, this.W, this, !0);
    a.onupgradeneeded = vq(c, this.oa, this, !0)
}
y(Vs, Bs);
Vs.prototype.W = function(a) {
    Ji(this.g);
    this.B && this.B(a)
}
;
Vs.prototype.oa = function(a) {
    Ji(this.g);
    if (a.dataLoss && "none" != a.dataLoss) {
        var c = {};
        c.dataLoss = a.dataLoss;
        c.dataLossMessage = a.dataLossMessage;
        c.optinBackup = ao(this.V);
        c.requestContext = this.I;
        c.unsavedChanges = Us(this.o);
        this.o.info(Error("tb"), c)
    }
    this.L && this.L(a)
}
;
Vs.prototype.J = function(a) {
    Bs.prototype.J.call(this, a);
    a.onblocked = rg;
    a.onupgradeneeded = rg
}
;
function Ws(a, c) {
    if (a.B)
        throw Error("ub");
    a.B = c
}
function Xs(a, c) {
    if (a.L)
        throw Error("vb");
    a.L = c
}
;function Ys(a, c, d, e, f) {
    this.g = a;
    this.A = c;
    this.v = d;
    this.j = e;
    this.o = f
}
Ys.prototype.get = function(a) {
    return new Bs(this.g.get(a),this.j,this.g.name + ".get(" + a + ")",this.A,this.v,this.o)
}
;
function Zs(a, c, d, e, f) {
    this.g = a;
    this.A = c;
    this.v = d;
    this.j = e;
    this.o = f
}
Zs.prototype.get = function(a) {
    return new Bs(this.g.get(a),this.j,this.g.name + ".get(" + a + ")",this.A,this.v,this.o)
}
;
Zs.prototype.put = function(a, c) {
    a = void 0 !== c ? this.g.put(a, c) : this.g.put(a);
    return new Bs(a,this.j,this.g.name + ".put(" + c + ")",this.A,this.v,this.o)
}
;
Zs.prototype.add = function(a, c) {
    a = void 0 !== c ? this.g.add(a, c) : this.g.add(a);
    return new Bs(a,this.j,this.g.name + ".add(" + c + ")",this.A,this.v,this.o)
}
;
function Ds(a, c) {
    return new Bs(a.g["delete"](c),a.j,a.g.name + ".delete(" + c + ")",a.A,a.v,a.o)
}
Zs.prototype.clear = function() {
    return new Bs(this.g.clear(),this.j,this.g.name + ".clear()",this.A,this.v,this.o)
}
;
function As(a, c) {
    return new Ys(a.g.index(c),a.A,a.v,a.j,a.o)
}
;function $s(a, c, d, e, f, g, h, k, l, m, p, r) {
    var u = this;
    this.F = a;
    this.fa = c;
    this.J = d;
    this.o = e;
    this.M = f;
    this.H = !1;
    this.A = void 0 === l ? !1 : l;
    this.D = this.B = null;
    this.j = new Ts;
    this.S = new Ss;
    this.V = m || 6E4;
    this.v = new Ps(function() {
        if (!u.j.j) {
            var w = at(u);
            w.transactionTimeout = u.V;
            w.timeoutDelays = u.v.o.concat().toString();
            w.documentHidden = document.hidden || document.webkitHidden;
            u.o.info(Error("yb`" + u.J), w);
            u.v.X();
            u.I && (bt(u, !0),
            u.I(),
            u.D.oncomplete = null)
        }
    }
    ,this.V,document);
    this.I = void 0 === p ? null : p;
    this.L = h;
    this.O = k;
    this.g = null;
    this.P = ct++;
    this.C = g;
    this.W = void 0 !== r ? r : this.A ? "idbrwt" : "idbrot";
    this.oa = null
}
v = $s.prototype;
v.open = function() {
    null != this.W && (this.g = rj(this.L, this.W, !0));
    var a = this.A ? "readwrite" : "readonly"
      , c = S(this.O, "docs-eisd") ? {
        durability: "strict"
    } : void 0;
    this.v.start();
    try {
        var d = this.F.transaction(this.fa, a, c)
    } catch (e) {
        throw a = at(this),
        Gi(e, a);
    }
    d.onabort = vq(this.o, this.kd, this);
    d.oncomplete = vq(this.o, this.ld, this);
    d.onerror = vq(this.o, this.Gc, this, !0);
    this.D = d;
    this.C.add(this)
}
;
function Gs(a) {
    a.j.j = !0;
    a.v.X();
    a.g && (uj(a.L, a.g),
    a.g = null);
    et(a.C, a)
}
v.abort = function(a) {
    bt(this, !1, a)
}
;
function bt(a, c, d) {
    var e = a.j;
    if (!e.o && !e.g) {
        if (!a.D)
            throw Error("xb");
        e.g = !0;
        try {
            a.D.abort()
        } catch (f) {
            "InvalidStateError" == f.name && c || (e = at(a),
            e.abortFromTimeout = c,
            a.o.info(f, e))
        }
        d && !a.H && (a.M(d),
        a.H = !0);
        a.v.X();
        et(a.C, a)
    }
}
function Z(a, c) {
    if (!a.D)
        throw Error("xb");
    return new Zs(a.D.objectStore(c),a.j,a.S,a.o,a.L)
}
function ft(a, c) {
    if (a.B)
        throw Error("wb");
    a.B = c
}
v.Ka = q("j");
v.kd = function(a) {
    this.j.j || (this.j.o = !0,
    this.g && (uj(this.L, this.g),
    this.g = null),
    et(this.C, this),
    this.v.X(),
    this.j.g || (a.target.docs_internalAbort = !0,
    !this.A && a.target.error && "QuotaExceededError" == a.target.error.name ? this.B && this.B() : gt(this, "LocalStore IndexedDB transaction abort", at(this), a)))
}
;
v.ld = function() {
    this.j.j || (et(this.C, this),
    this.g && (tj(this.L, this.g),
    this.g = null),
    this.v.X(),
    this.B && this.B())
}
;
v.Gc = function(a) {
    a.stopPropagation();
    var c = this.j;
    if (!(c.j || c.o || c.g || (c = a.target.error,
    c && "AbortError" == c.name)) && (c = at(this),
    c.request = a.target.docs_requestContext,
    gt(this, "LocalStore IndexedDB error", c, a),
    a = this.C,
    S(this.O, "docs-ewtaoe") && this.A)) {
        delete a.g[this.R()];
        c = 0;
        for (var d in a.g) {
            var e = Number(d)
              , f = a.g[e];
            f.A && (f.abort(),
            delete a.g[e],
            c++)
        }
        a.j = !0;
        a.o.info(Error("zb`" + this.R() + "`" + c))
    }
}
;
function gt(a, c, d, e) {
    c = c + " (" + a.J + "): " + xq(e);
    a.o.info(Error(c), d);
    d = new Qk(1,c,e,a.oa);
    a.H || (a.M(d),
    a.H = !0)
}
v.R = q("P");
function at(a) {
    var c = yq(a.F.objectStoreNames);
    c = {
        databaseName: a.F.name,
        databaseObjectStores: c,
        databaseVersion: a.F.version,
        transactionAllowWrite: a.A,
        transactionContext: a.J,
        transactionId: a.P,
        transactionObjectStores: a.fa.toString()
    };
    a = a.S;
    var d = vg(a.g);
    c.pendingRequestCount = d.length;
    c.pendingRequests = d.toString();
    c.requestErrorCount = a.j;
    c.requestSuccessCount = a.o;
    return c
}
function ht(a) {
    this.o = a;
    this.g = {};
    this.j = !1
}
ht.prototype.add = function(a) {
    if (a.A || !this.j)
        this.g[a.R()] = a
}
;
function et(a, c) {
    delete a.g[c.R()]
}
var ct = 0;
function it(a, c) {
    Io.call(this, "j", c);
    this.newVersion = a
}
y(it, Io);
function jt(a, c, d, e) {
    Q.call(this);
    this.j = a;
    this.A = c;
    this.H = d;
    this.B = e;
    this.g = null;
    this.v = !1;
    this.F = new ht(c);
    this.D = new Sj;
    R(this, this.D);
    this.o = new Sj;
    R(this, this.o);
    this.I = z.indexedDB || z.webkitIndexedDB
}
y(jt, Q);
jt.prototype.close = function() {
    this.g && (this.g.onversionchange = null,
    this.g.close(),
    this.g = null)
}
;
function kt(a, c) {
    if (a.g)
        throw Error("Ab");
    if (null != c.onversionchange)
        throw Error("Bb");
    c.onclose = function() {
        var d = {};
        d.optinBackup = ao(a.B);
        a.A.info(Error("Cb"), d);
        a.D.dispatchEvent(null)
    }
    ;
    c.onerror = Hs("Database error.", a.j);
    c.onversionchange = function(d) {
        a.v = !0;
        a.close();
        a.o.dispatchEvent(new it(Number(d.version) || d.newVersion || 0))
    }
    ;
    a.g = c
}
function lt(a) {
    if (!a.g)
        return -1;
    a = parseInt(a.g.version, 10);
    return 0 <= a ? a : -1
}
function mt(a, c, d, e, f, g, h, k) {
    if (!a.g)
        throw Error("Db");
    if (f && a.F.j)
        throw Error("Eb");
    a = new $s(a.g,c,d,a.A,e || a.j,a.F,a.H,a.B,f,g,h,k);
    a.open();
    return a
}
function nt(a, c, d, e, f) {
    if (lt(a) >= c)
        throw Error("Fb`" + c + "`" + lt(a));
    var g = a.g.name;
    a.close();
    var h = a.A;
    c = new Vs(a.I.open(g, c),h,"setVersion database.open",a.H,a.B);
    Xs(c, function(k) {
        k = k.target.transaction;
        k.onabort = k.onerror = vq(h, e, {}, !0);
        d(k)
    });
    Rs(c, e);
    Ws(c, function(k) {
        h.info(Error("Gb"), {
            "Old version": k.oldVersion,
            "New version": k.newVersion
        })
    });
    Es(c, function(k) {
        kt(a, k.target.result);
        f(k)
    })
}
jt.prototype.K = function() {
    this.close();
    Q.prototype.K.call(this)
}
;
function ot(a, c, d, e, f, g, h, k, l) {
    f = f ? function() {
        e(new Qk(6,"Timeout opening database."))
    }
    : void 0;
    l && (h.j("odbs"),
    kp(A(h.j, h, "odbjy")));
    f = new Vs((z.indexedDB || z.webkitIndexedDB).open("GoogleDocs"),d,"database.open",g,k,f,Fj(k, "docs-localstore-iort"),"idbodb");
    Es(f, function(m) {
        l && h.j("odbc");
        var p = new jt(c,d,g,k);
        kt(p, m.target.result);
        a(p)
    });
    Rs(f, Hs("Error opening database.", e))
}
;function pt() {
    this.g = !1
}
y(pt, gl);
pt.prototype.ha = function() {
    throw Error("Hb");
}
;
pt.prototype.ea = function(a) {
    throw Error("Ib`" + a.getType());
}
;
function qt(a, c, d) {
    this.g = !1;
    this.j = d
}
y(qt, hl);
qt.prototype.ha = function() {
    return ["Comments"]
}
;
qt.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "update-record":
        c = Z(c, "Comments");
        V(a);
        if (a.ja) {
            var d = a.Y
              , e = {};
            e.cmtKey = V(a);
            e.stateIndex = [d.s, d.di];
            e.da = d.da;
            c.put(e)
        } else {
            e = a.Y;
            a = V(a);
            var f = {};
            "s"in e && (f.stateIndex = [e.s, a[0]],
            delete e.s);
            for (d in e)
                f[d] = e[d];
            rt(this.j, a, f, c)
        }
        break;
    case "delete-record":
        c = Z(c, "Comments");
        a = V(a);
        Ds(c, a);
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function st() {
    this.g = !1
}
y(st, zl);
function tt(a, c, d, e, f, g) {
    il.call(this, e, g);
    this.j = a;
    this.A = d;
    this.v = g
}
y(tt, il);
function ut(a, c, d, e) {
    if (a.j.v)
        kp(function() {
            return d([])
        });
    else {
        var f = mt(a.j, ["Documents"], "Error reading documents.", e);
        vt(a, c, function(g) {
            Gs(f);
            d(g)
        }, f)
    }
}
function wt(a, c, d) {
    ut(a, c, function(e) {
        1 == e.length ? d(e[0]) : d(null)
    })
}
function vt(a, c, d, e) {
    c ? Es(Z(e, "Documents").get(c), function(f) {
        (f = f.target.result) ? d([xt(a, f)]) : d([])
    }) : Fs(e, function(f) {
        return xt(a, f)
    }, d)
}
function xt(a, c) {
    if (c.hpmdo)
        return null;
    var d = new Dk(c.id,c.documentType,!1,a.v);
    X(d, "title", c.title);
    X(d, "lastSyncedTimestamp", c.lastSyncedTimestamp);
    Fk(d, c.jobset);
    W(d, "isFastTrack", !!c.isFastTrack);
    X(d, "lastModifiedServerTimestamp", c.lastModifiedServerTimestamp);
    X(d, "lastColdStartedTimestamp", c.lastColdStartedTimestamp);
    X(d, "lastWarmStartedTimestamp", c.lastWarmStartedTimestamp);
    var e = c.acl;
    for (g in e)
        ok(d, "acl", g, Rb(e[g]));
    e = c.acjf;
    for (var f in e) {
        var g = $i(e[f]);
        Hk(d, f, g)
    }
    X(d, "docosKeyData", c.docosKeyData || null);
    W(d, "inc", !!c.inc);
    f = c.lastModifiedClientTimestamp;
    null != f && Ik(d, f);
    if (f = c.startupHints)
        for (var h in f)
            ok(d, "startupHints", h, f[h]);
    (h = c.ic) && Lk(d, h);
    W(d, "hpmdo", !!c.hpmdo);
    W(d, "ips", !!c.ips);
    W(d, "ip", !!c.ip);
    W(d, "pendingCreation", !!c.pendingCreation);
    h = c.fact;
    null != h && X(d, "fact", h);
    W(d, "modelNeedsResync", !!c.modelNeedsResync);
    W(d, "ind", !!c.ind);
    W(d, "isd", !!c.isd);
    W(d, "ist", !!c.ist);
    W(d, "ende", !!c.ende);
    h = c.mimeType;
    null != h && X(d, "mimeType", h);
    W(d, "ibup", !!c.ibup);
    h = c.modelVersion;
    null != h && X(d, "modelVersion", h);
    h = c.featureVersion;
    null != h && X(d, "featureVersion", h);
    h = c.featureBitSetModelVersion;
    null != h && X(d, "featureBitSetModelVersion", h);
    h = c.featureBitSetBase64String;
    null != h && X(d, "featureBitSetBase64String", h);
    h = c.rev;
    null != h && (f = c.rai,
    null != f ? f = f ? new Sk(f[0]) : null : f = null,
    Gk(d, h, f));
    h = c.lsst;
    null != h && X(d, "lsst", h);
    h = c.lss;
    null != h && W(d, "lss", !!h);
    h = c.lsft;
    null != h && X(d, "lsft", h);
    h = c.odocid;
    null != h && X(d, "odocid", h);
    h = c.relevancyRank;
    null != h && X(d, "relevancyRank", h);
    h = c.lastServerSnapshotTimestamp;
    null != h && X(d, "lastServerSnapshotTimestamp", h);
    h = c.snapshotState;
    null != h && (h = Rb(h),
    X(d, "snapshotState", h));
    h = c.snapshotProtocolNumber;
    void 0 !== h && (Zh(null == h || 0 <= h, "pa"),
    X(d, "snapshotProtocolNumber", h));
    h = c.snapshotVersionNumber;
    void 0 !== h && (Zh(null == h || 0 <= h, "qa"),
    X(d, "snapshotVersionNumber", h));
    h = c.pendingQueueState;
    null != h && (h = Rb(h),
    X(d, "pendingQueueState", h));
    h = c.fileLockedReason;
    null != h && X(d, "fileLockedReason", h);
    h = c.quotaStatus;
    null != h && (h = Rb(h),
    X(d, "quotaStatus", h));
    h = c.isOwner;
    null != h && W(d, "isOwner", !!h);
    h = c.approvalMetadataStatus;
    null != h && X(d, "approvalMetadataStatus", h);
    h = c.contentLockType;
    null != h && X(d, "contentLockType", h);
    h = c.initialSyncReason;
    null == h || null == hk(d, "initialSyncReason") && X(d, "initialSyncReason", h);
    h = c.resourceKey;
    null != h && X(d, "resourceKey", h);
    c = c.initialPinSourceApp;
    null != c && X(d, "initialPinSourceApp", c);
    if (!d || "trix" == d.getType() || "syncstats" == d.getType())
        return null;
    if (!a.Yb[d.getType()])
        throw a = Error("Jb`" + d.getType()),
        Gi(a, {
            localStoreDoc_hasTitle: !!ik(d, "title"),
            localStoreDoc_id: d.R(),
            localStoreDoc_isCreated: (!0 !== jk(d, "inc")).toString(),
            localStoreDoc_lastModifiedClientTimestamp: gk(d, "lastModifiedClientTimestamp").toString(),
            localStoreDoc_lastModifiedServerTimestamp: gk(d, "lastModifiedServerTimestamp").toString(),
            localStoreDoc_lastSyncedTimestamp: gk(d, "lastSyncedTimestamp").toString(),
            localStoreDoc_revision: hk(d, "rev").toString()
        });
    d.o = !1;
    return d
}
tt.prototype.ha = function(a) {
    if (!this.aa(a))
        throw Error("Kb`" + a.getType());
    var c = ["DocumentCommands", "Documents"];
    "delete-record" == a.getType() && (c = c.concat(["Comments", "DocumentEntities", "PendingQueueCommands", "PendingQueues"]));
    return c
}
;
tt.prototype.ea = function(a, c) {
    var d = Z(c, "Documents");
    switch (a.getType()) {
    case "update-record":
        a.ja ? d.add(a.Y) : rt(this.A, V(a), a.Y, d, yt);
        break;
    case "delete-record":
        zt(this, a, c);
        break;
    default:
        this.Ia(a.v).ea(a, c)
    }
}
;
function zt(a, c, d) {
    c.j ? a.o(c, d) : At(V(c), d, function(e) {
        e ? d.abort(new Qk(5,"Pending changes found")) : a.o(c, d)
    })
}
function At(a, c, d) {
    Es(ys(Z(c, "PendingQueueCommands"), [a], [a, []]), function(e) {
        e.target.result ? d(!0) : Bt(a, c, d)
    })
}
function Bt(a, c, d) {
    Es(As(Z(c, "Comments"), "StateIndex").get([2, a]), function(e) {
        d(!!e.target.result)
    })
}
tt.prototype.o = function(a, c) {
    a = V(a);
    var d = Z(c, "DocumentCommands");
    Cs(d, [a], [a, []]);
    Ct(a, c);
    d = Z(c, "Documents");
    Cs(d, a);
    d = Z(c, "DocumentLocks");
    Cs(d, [a]);
    d = Z(c, "Comments");
    Cs(d, [a], [a, []]);
    Dt(this.j, "nonsnapshottedocumentids", [a], n());
    Dt(this.j, "missingdocosdocumentids", [a], n());
    c = Z(c, "DocumentEntities");
    Cs(c, [a], [a, []])
}
;
function Ct(a, c) {
    var d = Z(c, "PendingQueueCommands");
    Cs(d, [a], [a, []]);
    c = Z(c, "PendingQueues");
    Cs(c, a)
}
var yt = "approvalMetadataStatus contentLockType initialPinSourceApp lastModifiedClientTimestamp lastWarmStartedTimestamp quotaStatus relevancyRank rev rai snapshotProtocolNumber snapshotVersionNumber odocid".split(" ");
function Et() {}
Et.prototype.g = function(a, c, d, e, f, g) {
    return new tt(a,c,d,e,f,g)
}
;
function Ft(a, c, d, e, f) {
    jl.call(this, d, f);
    this.j = a;
    this.o = e
}
y(Ft, jl);
function An(a, c, d, e) {
    var f = mt(a.j, ["NewDocumentIds"], "Error reading new document ids.", e, !0)
      , g = Z(f, "NewDocumentIds").get(c)
      , h = e || a.j.j;
    Es(g, function(k) {
        return Gt(c, f, d, h, k)
    })
}
function Gt(a, c, d, e, f) {
    if ((f = f.target.result) && f.documentIds && 0 != f.documentIds.length) {
        e = f.documentIds;
        var g = e.pop();
        a = Ht(a, e);
        Z(c, "NewDocumentIds").put(a);
        ft(c, function() {
            d(g)
        })
    } else
        e(new Qk(3,"No document IDs in storage."))
}
function Ht(a, c) {
    var d = {};
    d.dtKey = a;
    d.documentIds = c;
    return d
}
function xn(a, c, d, e) {
    var f = mt(a.j, ["ApplicationMetadata"], "Error reading application metadata.", e);
    Es(Z(f, "ApplicationMetadata").get(c), function(g) {
        Gs(f);
        var h = g.target.result;
        if (h) {
            var k = h.dt;
            if (null == k)
                throw Error("Lb");
            g = new Uk(k,!1,a.Ba);
            k = a.Ia(k);
            var l = h.jobset;
            null != l && X(g, "jobset", l);
            l = h.ic;
            null != l && (k = k.bc(l),
            g.C = k.slice(0),
            g.j = !0);
            (k = h.docosKeyData) && X(g, "docosKeyData", k);
            h = h.version;
            h = Rb(void 0 !== h ? h : 0);
            X(g, "version", h);
            g.o = !1;
            d(g)
        } else
            d(null)
    })
}
Ft.prototype.ha = function(a) {
    if (!this.aa(a))
        throw Error("Kb`" + a.getType());
    return ["ApplicationMetadata"]
}
;
Ft.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "update-application-metadata":
        var d = this.Ia(V(a))
          , e = a.Y;
        if (a.j) {
            if (a.j)
                var f = a.j;
            else
                throw D("wa").N;
            for (var g = [], h = 0; h < f.length; h++)
                g.push(d.Db.Z(f[h]));
            e.ic = g
        }
        c = Z(c, "ApplicationMetadata");
        a.ja ? c.put(e) : rt(this.o, V(a), e, c);
        break;
    default:
        throw Error("Mb`" + a.getType());
    }
}
;
function It(a, c, d) {
    this.g = !1;
    this.j = d
}
y(It, ll);
It.prototype.ha = function() {
    return ["DocumentEntities"]
}
;
It.prototype.ea = function(a, c) {
    c = Z(c, "DocumentEntities");
    switch (a.getType()) {
    case "update-record":
        if (a.ja) {
            var d = {};
            d.deKey = V(a);
            d.data = a.Y.data;
            c.put(d)
        } else
            d = {},
            d.data = a.Y.data,
            a = V(a),
            rt(this.j, a, d, c);
        break;
    case "delete-record":
        Cs(c, V(a));
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function Jt(a, c, d, e) {
    this.j = a;
    this.v = c;
    this.g = d;
    this.o = e
}
Jt.prototype.Z = function() {
    var a = {};
    a.e = this.j;
    a.dlKey = [this.v];
    a.sId = this.g;
    a.cId = this.o;
    return a
}
;
function Kt(a) {
    this.g = !1;
    this.j = a
}
y(Kt, ml);
v = Kt.prototype;
v.Sb = function(a, c, d) {
    this.j.Sb(a, c, d)
}
;
v.cc = function() {
    this.j.cc()
}
;
v.ha = function() {
    return ["DocumentLocks"]
}
;
v.ea = function(a, c) {
    switch (a.getType()) {
    case "document-lock":
        switch (a.o) {
        case 2:
            Lt(this.j, a.j, c);
            break;
        case 1:
            Mt(this.j, a.j, c)
        }
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
v.K = function() {
    ml.prototype.K.call(this);
    this.j.X()
}
;
function Nt() {}
;function Ot(a, c, d, e, f, g, h) {
    Q.call(this);
    var k = this;
    this.o = a;
    this.j = c;
    this.v = d;
    this.S = f;
    this.V = g || this.v.j;
    this.B = 0;
    this.I = e;
    this.M = new Uj;
    R(this, this.M);
    Vj(this.M, d.o, function() {
        k.cc()
    });
    this.J = new np(this);
    this.A = new Sj;
    R(this, this.A);
    this.P = this.D = null;
    this.O = !1;
    this.g = this.F = null;
    this.H = h
}
y(Ot, Q);
Ot.prototype.Sb = function(a, c, d) {
    z.navigator.locks ? Pt(this, a, c, d) : Qt(this, a, c, d)
}
;
function Pt(a, c, d, e) {
    function f(k) {
        g = !0;
        a.H && Rt(a, k);
        d(k)
    }
    var g = !1
      , h = !1;
    a.P = z.navigator.locks.request("GoogleDocs:document:" + c, {
        ifAvailable: !0
    }, function(k) {
        if (!k)
            return Promise.resolve(2);
        0 != a.j && (a.O = !0);
        return (new Promise(function(l, m) {
            var p = St(a, function() {
                l(4)
            }, function(r) {
                h = !0;
                m(r)
            });
            a.A.dispatchEvent(null);
            Tt(a, c, p, l)
        }
        )).then(function(l) {
            if (0 == a.j)
                return l;
            if (1 != l)
                f(l);
            else {
                var m = oh();
                a.D = m.resolve;
                f(l);
                return m.promise
            }
        })
    }).then(function(k) {
        g ? a.F || Ut(a, "databaseLockNotAcquired") : (Ut(a, "transientRelease"),
        f(k))
    }, vq(a.I, function(k) {
        Ut(a, "acquisitionRejected");
        if (h)
            e(k);
        else
            throw Gi(k, {
                "docs-origin-class": "docs.localstore.idb.LockManager"
            });
    }, a))
}
function Rt(a, c) {
    z.navigator.locks && z.navigator.locks.query().then(function(d) {
        a.H.g(d.held.length - (1 == c ? 1 : 0))
    })
}
function Qt(a, c, d, e) {
    var f = St(a, function() {
        d(4)
    }, e);
    Vt(a, c, f, function(g, h) {
        "unavailable" == g && Wt(a, h, "acquireDocumentLock");
        "available" == g || "expiredOtherSid" == g ? (a.A.dispatchEvent(null),
        Xt(a, c, f, h, function() {
            ft(f, function() {
                Yt(a, c);
                d(1)
            })
        })) : (f.I = null,
        d(2))
    }, e)
}
function St(a, c, d) {
    return mt(a.v, ["DocumentLocks"], "Lock acquisition", d, !0, Fj(a.S, "docs-localstore-ilat"), c, "idbla")
}
function Yt(a, c) {
    if (a.g)
        throw Error("Nb");
    a.wa() || 0 == a.j || (a.g = new jp(Math.max(a.j - 1E4, 0)),
    qp(a.J, a.g, "tick", function() {
        Zt(a, c, 0)
    }),
    a.g.start())
}
function Mt(a, c, d) {
    Vt(a, c, d, function(e, f) {
        "unavailable" == e && (Wt(a, f, "ensureDocumentLockAvailable"),
        d.abort(new Qk(2,"Lock not available")))
    })
}
function Lt(a, c, d) {
    if (z.navigator.locks)
        $t(a, c, d);
    else {
        a.g && a.g.stop();
        var e = function() {
            Ji(a.g);
            a.g = null;
            d.abort(new Qk(2,"Lock could not be refreshed"))
        };
        au(a, c, d, function(f) {
            f && f.g == a.o ? Xt(a, c, d, f, function() {
                a.g && a.g.start()
            }, e) : (Wt(a, f, "refreshDocumentLock"),
            e())
        }, e)
    }
}
function $t(a, c, d) {
    au(a, c, d, function(e) {
        e && e.g == a.o || (Wt(a, e, "ensureDocumentLockOwner"),
        d.abort(new Qk(2,"Lock not available: session is not the current lock-holder")))
    }, function(e) {
        d.abort(e)
    })
}
function au(a, c, d, e, f) {
    c = Z(d, "DocumentLocks").get([c]);
    Es(c, function(g) {
        a.wa() || (g = g.target.result,
        e(g ? new Jt(g.e,g.dlKey[0],g.sId,g.cId || null) : null))
    });
    f && Rs(c, sg(f))
}
function Vt(a, c, d, e, f) {
    au(a, c, d, function(g) {
        if (g) {
            var h = 0 == a.j;
            var k = Date.now();
            if (g.g == a.o)
                h = "available";
            else {
                var l = window.localStorage;
                h = l && l.getItem("dcl_" + g.g) ? "available" : g.j + (h ? 6E4 : 0) <= k || g.j > k + 36E4 ? "expiredOtherSid" : "unavailable"
            }
        } else
            h = "available";
        e(h, g)
    }, f)
}
function Wt(a, c, d) {
    if (!(0 >= a.j)) {
        var e = Date.now()
          , f = {};
        f.lockReadReason = d;
        f.lockDuration = a.j;
        a.B && (f.lastWrittenValidUntil = a.B - e);
        var g = "IndexedDB document lock not available";
        if (c) {
            if (f.lockHoldingSessionId = c.g,
            f.validUntil = c.j - e,
            z.navigator.locks)
                if ("acquireDocumentLock" == d)
                    g = "IndexedDB document lock not available after Web Locks API fallback";
                else if ("ensureDocumentLockOwner" == d || "refreshDocumentLock" == d)
                    c = (d = window.localStorage) && d.getItem("dcl_" + c.g),
                    f.lockReleased = !!c,
                    f.webLockHasBeenAcquired = a.O,
                    f.webLockReleaseReason = a.F
        } else
            g = "IndexedDB document lock not available because the lock does not exist";
        a.I.info(Error(g), f)
    }
}
function Ut(a, c) {
    0 != a.j && (a.F = c)
}
function Xt(a, c, d, e, f, g) {
    var h = Date.now()
      , k = 0;
    e && a.o == e.g && (k = e.j);
    e = Math.min(Math.max(h + a.j, k), h + 6E4);
    a.B = e;
    bu(a, c, d, e, f, g)
}
function Tt(a, c, d, e) {
    bu(a, c, d, 0, function() {
        ft(d, function() {
            e(1)
        })
    })
}
function bu(a, c, d, e, f, g) {
    a = Z(d, "DocumentLocks").put((new Jt(e,c,a.o,null)).Z());
    Es(a, sg(f));
    g && Rs(a, sg(g))
}
function Zt(a, c, d) {
    var e = mt(a.v, ["DocumentLocks"], "Lock refresh timer", function(f) {
        a.wa() || (2 == f.type || 2 <= d ? (Ji(a.g),
        a.g = null,
        a.V(f)) : Zt(a, c, d + 1))
    }, !0);
    Lt(a, c, e)
}
Ot.prototype.cc = function() {
    if (z.navigator.locks)
        this.D && (this.D(),
        Ut(this, "releaseAllLocks")),
        this.P || Promise.resolve();
    else {
        Ji(this.g);
        this.g = null;
        var a = window.localStorage;
        if (a)
            try {
                a.setItem("dcl_" + this.o, String(Date.now()))
            } catch (e) {
                for (var c = 0, d = 0; d < a.length; d++)
                    lc(a.key(d), "dcl_") && c++;
                throw Gi(e, {
                    keysTotal: String(a.length),
                    locksTotal: String(c)
                });
            }
        Promise.resolve()
    }
}
;
Ot.prototype.K = function() {
    this.J.X();
    Ji(this.g);
    this.g = null;
    Q.prototype.K.call(this)
}
;
function cu() {
    this.g = !1
}
y(cu, ql);
cu.prototype.ha = function() {
    return ["Impressions"]
}
;
cu.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "update-record":
        if (a.ja) {
            c = Z(c, "Impressions");
            a = a.Y;
            var d = {};
            d.iKey = [a.di || "", a.ibt];
            d.dt = a.dt;
            d.iba = a.iba;
            c.put(d)
        } else
            throw Error("Ob");
        break;
    case "delete-record":
        Cs(Z(c, "Impressions"), V(a));
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function du() {
    this.g = !1
}
y(du, rl);
function eu(a, c, d, e, f) {
    Hl.call(this, d, new lj(e), f)
}
y(eu, Hl);
eu.prototype.ha = function() {
    return ["PendingQueueCommands", "PendingQueues"]
}
;
eu.prototype.ea = function(a, c) {
    var d = this;
    a instanceof Wj && !a.ja ? Es(Z(c, "PendingQueues").get(V(a)), function(e) {
        e = e.target.result;
        if (!e)
            throw Error("Pb");
        fu(d, a, c, e)
    }) : fu(this, a, c)
}
;
function fu(a, c, d, e) {
    if (e) {
        var f = c.Y
          , g = f.revision
          , h = f.revisionAccessInfo;
        null != g && (e.r = g);
        void 0 !== h && (e.ra = h);
        g = f.selection;
        null != g && (e.s = g);
        g = f.accessLevel;
        null != g && (e.a = g);
        g = f.undeliverable;
        void 0 !== g && (e.u = !!g);
        g = f.unsavedChanges;
        void 0 !== g && (e.uc = !!g);
        h = f.sentBundlesSavedRevision;
        void 0 !== h && (e.sbsr = h);
        h = f.unsentBundleMetadata;
        void 0 !== h && (e.ubm = h);
        f = f.snapshotBundleIndex;
        void 0 !== f && (e.sbi = f);
        if (g) {
            a = a.g.g;
            try {
                z.localStorage.setItem("docs-ucb", "1")
            } catch (k) {
                a.info(Error("rb`" + k.message))
            }
        }
    }
    switch (c.getType()) {
    case "pq-clear":
        e = e || gu(c);
        c = V(c);
        a = Z(d, "PendingQueueCommands");
        Cs(a, [c], [c, []]);
        e.b = [];
        hu(e, d);
        break;
    case "pq-clear-sent":
        e = e || gu(c);
        a = e.b;
        0 < a.length && (a = a[a.length - 1].l,
        f = Z(d, "PendingQueueCommands"),
        c = V(c),
        Cs(f, [c], [c, a]),
        e.b = []);
        hu(e, d);
        break;
    case "pq-clear-sent-bundle":
        e = e || gu(c);
        a = e.b.shift().l;
        f = Z(d, "PendingQueueCommands");
        c = V(c);
        Cs(f, [c], [c, a]);
        hu(e, d);
        break;
    case "pq-mark-sent":
        e = e || gu(c);
        a = c.j;
        c.v && (e.b = []);
        for (c = 0; c < a.length; c++)
            f = a[c],
            g = {},
            g.l = f.g,
            g.s = f.o,
            g.r = f.j,
            e.b.push(g);
        hu(e, d);
        break;
    case "update-record":
        hu(e || gu(c), d);
        break;
    case "pq-write-commands":
        e = c.o;
        a = {};
        a.pqcKey = [c.v, c.j];
        a.c = e;
        Z(d, "PendingQueueCommands").put(a);
        break;
    case "pq-delete-commands":
        d = Z(d, "PendingQueueCommands");
        e = c.j;
        Cs(d, [e], [e, c.o]);
        break;
    default:
        throw Error("Qb`" + c.getType());
    }
}
function hu(a, c) {
    Z(c, "PendingQueues").put(a)
}
function gu(a) {
    var c = a.Y;
    a = {};
    var d = c.accessLevel;
    void 0 !== d && (a.a = d);
    a.docId = c.docId;
    a.r = c.revision;
    a.ra = c.revisionAccessInfo;
    a.ubm = c.unsentBundleMetadata;
    a.s = c.selection;
    a.b = [];
    a.t = c.documentType;
    a.u = !!c.undeliverable;
    a.uc = !!c.unsavedChanges;
    d = c.sentBundlesSavedRevision;
    null != d && (a.sbsr = d);
    c = c.snapshotBundleIndex;
    void 0 !== c && (a.sbi = c);
    return a
}
;function iu() {}
function rt(a, c, d, e, f) {
    d && (f = f || [],
    Es(e.get(c), A(a.g, a, e, d, f)))
}
iu.prototype.g = function(a, c, d, e) {
    e = e.target.result;
    if (void 0 !== e) {
        for (var f in c) {
            var g = c[f];
            Tc(d, f) ? e[f] = null != g ? g : null : e[f] = g
        }
        a.put(e)
    } else
        throw Error("Rb");
}
;
function Dt(a, c, d, e) {
    var f = mt(a, ["ProfileData"], "Error removing document ids", void 0, !0);
    ju(c, function(g) {
        for (var h = 0; h < d.length; h++)
            Uc(g, d[h]);
        h = {};
        h.dataType = c;
        h.documentIds = g;
        Z(f, "ProfileData").put(h);
        ft(f, e)
    }, f)
}
function ju(a, c, d) {
    Es(Z(d, "ProfileData").get(a), function(e) {
        e = e.target.result;
        c(e && e.documentIds ? e.documentIds : [])
    })
}
;function ku(a, c, d, e, f) {
    um.call(this, f);
    this.j = a;
    this.v = d;
    this.o = e
}
y(ku, um);
function lu(a, c, d) {
    if (a.j.v)
        kp(Ia(c, []));
    else if (Tc(a.j.g.objectStoreNames, "Users")) {
        d = mt(a.j, ["Users"], "Error reading users.", d);
        var e = [];
        Es(Z(d, "Users").get(Is.lowerBound(-Infinity)), function(f) {
            if (f = f.target.result) {
                var g = new sm(f.id,!1,a.Ba);
                X(g, "emailAddress", f.emailAddress);
                X(g, "locale", f.locale);
                null != f.fastTrack && W(g, "fastTrack", !!f.fastTrack);
                null != f.internal && W(g, "internal", !!f.internal);
                null != f.optInReasons && X(g, "optInReasons", f.optInReasons);
                null != f.optInTime && X(g, "optInTime", f.optInTime);
                g.o = !1;
                e = [g]
            }
        });
        ft(d, function() {
            return c(e)
        })
    } else
        a.o.log(Error("Sb")),
        kp(Ia(c, []))
}
ku.prototype.ha = function(a) {
    if (!this.aa(a))
        throw Error("Kb`" + a.getType());
    return ["Users"]
}
;
ku.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "update-record":
        c = Z(c, "Users");
        a.ja ? c.add(a.Y) : rt(this.v, V(a), a.Y, c);
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function mu(a, c, d, e, f, g, h) {
    Vl.call(this);
    var k = this;
    this.O = e;
    this.lb = new np(this);
    this.A = new xs;
    this.v = g;
    this.o = new iu;
    this.P = new Uj;
    Wh(this, this.P);
    this.j = a;
    Vj(this.P, this.j.o, function(l) {
        k.W.dispatchEvent(new Ul(l.newVersion))
    });
    this.M = c;
    this.L = new eu(this.j,this.A,this.M,this.O,g);
    Wl(this, this.L);
    this.C = nu(this, this.M, h);
    Wl(this, this.C);
    this.H = new Kt(d);
    this.J = new ku(a,this.A,this.o,e,g);
    Wl(this, this.J);
    this.Qb = new pt(a)
}
y(mu, Vl);
mu.prototype.rb = q("J");
function nu(a, c, d) {
    d = void 0 === d ? new Et : d;
    return d.g(a.j, a.A, a.o, c, a.O, a.v)
}
function yl(a, c, d, e) {
    if (a.j.v)
        kp(d);
    else {
        for (var f = {}, g = 0; g < c.length; g++) {
            var h = c[g];
            h = ou(a, h).ha(h);
            for (var k = 0; k < h.length; k++)
                f[h[k]] = !0
        }
        e = mt(a.j, wg(f), "Error writing records.", e, !0);
        ft(e, d);
        for (d = 0; d < c.length; d++)
            f = c[d],
            ou(a, f).ea(f, e)
    }
}
function ou(a, c) {
    if (Xj(c)) {
        c = c.o;
        a = c in a.B ? a.B[c] : null;
        if (!a)
            throw Error("Tb`" + c);
        return a
    }
    c = c.getType();
    if ("pq-clear" == c || "pq-clear-sent" == c || "pq-clear-sent-bundle" == c || "pq-delete-commands" == c || "pq-mark-sent" == c || "pq-write-commands" == c)
        return a.L;
    if ("document-lock" == c)
        return a.H;
    if ("append-commands" == c || "write-trix" == c)
        return a.C;
    if ("update-application-metadata" == c) {
        if (a = a.Xa())
            return a
    } else if ("append-template-commands" == c && (a = a.hc()))
        return a;
    throw Error("Ub`" + c);
}
function pu(a, c, d) {
    var e = a.qb();
    if (lt(a.j) >= e)
        throw Error("Vb");
    nt(a.j, e, function(f) {
        return qu(a, d, f)
    }, Hs("Error initializing the database.", d), c)
}
function qu(a, c, d) {
    try {
        a.nb(d)
    } catch (e) {
        kp(function() {
            return c(new Qk(1,"Failed to initialize database.",e))
        })
    }
}
function ru(a, c, d) {
    nt(a.j, a.qb(), function(e) {
        return su(a, d, e)
    }, Hs("Error upgrading the database.", d), c)
}
function su(a, c, d) {
    try {
        a.Xb(d)
    } catch (e) {
        kp(function() {
            return c(new Qk(1,"Failed to upgrade database.",e))
        })
    }
}
mu.prototype.K = function() {
    Ki(this.lb, this.H, this.L, this.C, this.J, this.Qb);
    Vl.prototype.K.call(this)
}
;
function tu(a, c, d, e) {
    this.g = !1;
    this.j = a;
    this.o = e;
    this.v = d
}
y(tu, em);
function gm(a, c, d) {
    var e = mt(a.j, ["ProfileData"], "Error reading all syncHints.", d)
      , f = [];
    Es(ys(Z(e, "ProfileData"), ["synchints"], ["synchints", []]), function(g) {
        (g = g.target.result) ? (f.push(uu(a, g.value)),
        g.continue()) : (Gs(e),
        c(f))
    })
}
tu.prototype.ha = function() {
    return ["ProfileData"]
}
;
tu.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "update-record":
        c = Z(c, "ProfileData");
        a.ja ? c.put(a.Y) : rt(this.v, V(a), a.Y, c);
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function uu(a, c) {
    var d = c.sourceApp;
    if (!Yc(c.dataType, ["synchints", "" + d]))
        throw Error("Wb");
    var e = c.docIds
      , f = c.lastUpdatedTimestamp;
    c = c.docIdentifiers;
    a = new am(!1,d,a.o);
    c && 0 < c.length ? bm(a, c.map(function(g) {
        return $l(g)
    })) : e && 0 < e.length && cm(a, e);
    X(a, "lastUpdatedTimestamp", f);
    a.o = !1;
    return a
}
;function vu() {
    this.g = !1
}
y(vu, hm);
vu.prototype.ha = function() {
    return ["SyncObjects"]
}
;
vu.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "update-record":
        c = Z(c, "SyncObjects");
        if (a.ja)
            c.put(a.Y);
        else
            throw Error("Xb");
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function wu(a, c, d) {
    nm.call(this, d);
    this.j = a;
    this.o = c
}
y(wu, nm);
function pm(a, c, d) {
    var e = mt(a.j, ["ProfileData"], "Error reading syncStats.", d);
    Es(Z(e, "ProfileData").get("syncstats"), function(f) {
        Gs(e);
        (f = f.target.result) ? c(xu(a, f)) : c(null)
    })
}
function xu(a, c) {
    if ("syncstats" != c.dataType)
        throw Error("Wb");
    a = new im(!1,a.Ba,Ln(function() {
        return Date.now()
    }));
    var d = c.docsToDelete;
    null != d && X(a, "docsToDelete", d);
    d = c.enabledMimeTypes;
    null != d && X(a, "enabledMimeTypes", d);
    d = c.lastLocalStoreProfileTimestamp;
    null != d && X(a, "lastLocalStoreProfileTimestamp", d);
    d = c.lastSyncTimestamp;
    null != d && X(a, "lastSyncTimestamp", d);
    d = c.syncStartTimestamp;
    null != d && X(a, "syncStartTimestamp", d);
    d = c.syncVersion;
    null != d && X(a, "syncVersion", d);
    d = c.failedToSyncDocs;
    if (null != d)
        for (var e in d) {
            var f = d[e]
              , g = f.lastSyncErrorType;
            lm(a, e, f.count, f.modelSyncFailCount || 0, f.serverTime, null != g ? null == g ? null : Rb(g) : null, f.nextSyncTimestampMillis || Date.now(), f.backoffRetryConsecutiveFailCount || 0)
        }
    e = c.lastDailyRunTime;
    null != e && X(a, "lastDailyRunTime", e);
    e = c.maxSpaceQuota;
    null != e && X(a, "maxSpaceQuota", e);
    e = c.webfontsSyncVersion;
    null != e && X(a, "webfontsSyncVersion", e);
    e = c.lastStartedSyncDocs;
    if (null != e)
        for (d = 0; d < e.length; d++)
            jm(a, e[d].documentId, e[d].timestamp);
    e = c.relevantDocuments;
    null != e && X(a, "relevantDocuments", e);
    c = c.backgroundSyncDenylist;
    if (null != c)
        for (var h in c)
            e = c[h],
            e = cl(bl(al($k(Zk(Yk(Xk(h), e.retryCount || 0), e.nextSyncTimestampMillis || Date.now()), e.firstFailTimestampMillis), e.lastFailTimestampMillis), e.documentDiskSize)),
            km(a, e);
    a.o = !1;
    return a
}
wu.prototype.ha = function() {
    return ["ProfileData"]
}
;
wu.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "update-record":
        c = Z(c, "ProfileData");
        a.ja ? c.put(a.Y) : rt(this.o, "syncstats", a.Y, c);
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function yu() {
    this.g = !1
}
y(yu, vm);
yu.prototype.ha = function() {
    return ["FontMetadata"]
}
;
yu.prototype.ea = function(a, c) {
    c = Z(c, "FontMetadata");
    switch (a.getType()) {
    case "update-record":
        if (a.ja)
            c.put(a.Y);
        else
            throw Error("Yb");
        break;
    case "delete-record":
        Cs(c, V(a));
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function zu(a, c, d, e, f, g, h, k, l) {
    mu.call(this, a, c, d, e, f, g, h, k, l);
    a = this.j;
    d = this.A;
    this.V = new It(a,d,this.o,this.v);
    Wl(this, this.V);
    this.ab = new yu(a,d,this.v);
    Wl(this, this.ab);
    this.Ea = new vu(a,d,this.v);
    Wl(this, this.Ea);
    this.Rb = new du(a);
    this.Hc = new st(a,this.o);
    this.I = new wu(a,this.o,this.v);
    Wl(this, this.I);
    this.oa = new tu(a,d,this.o,g);
    Wl(this, this.oa);
    this.S = new qt(this.j,this.A,this.o,this.v);
    Wl(this, this.S);
    this.F = new Ft(a,d,c,this.o,this.v);
    Wl(this, this.F);
    this.fa = new cu(a,d,g);
    Wl(this, this.fa)
}
y(zu, mu);
v = zu.prototype;
v.qb = aa(6);
v.Xa = q("F");
v.fc = q("I");
v.ec = q("oa");
v.Tb = aa(!1);
v.Xb = n();
v.nb = function(a) {
    a = a.db;
    a.createObjectStore("FontMetadata", {
        keyPath: "fontFamily"
    });
    a.createObjectStore("DocumentEntities", {
        keyPath: "deKey"
    });
    a.createObjectStore("SyncObjects", {
        keyPath: "keyPath"
    });
    a.createObjectStore("ProfileData", {
        keyPath: "dataType"
    });
    a.createObjectStore("ApplicationMetadata", {
        keyPath: "dt"
    });
    a.createObjectStore("NewDocumentIds", {
        keyPath: "dtKey"
    });
    a.createObjectStore("Comments", {
        keyPath: "cmtKey"
    }).createIndex("StateIndex", "stateIndex");
    a.createObjectStore("Users", {
        keyPath: "id"
    });
    a.createObjectStore("Documents", {
        keyPath: "id"
    });
    a.createObjectStore("DocumentCommands", {
        keyPath: "dcKey"
    });
    a.createObjectStore("DocumentCommandsStaging", {
        keyPath: "dcKey"
    });
    a.createObjectStore("DocumentCommandsMetadata", {
        keyPath: "dcmKey"
    });
    a.createObjectStore("DocumentCommandsMetadataStaging", {
        keyPath: "dcmKey"
    });
    a.createObjectStore("DocumentLocks", {
        keyPath: "dlKey"
    });
    a.createObjectStore("Impressions", {
        keyPath: "iKey"
    });
    a.createObjectStore("PendingQueues", {
        keyPath: "docId"
    });
    a.createObjectStore("PendingQueueCommands", {
        keyPath: "pqcKey"
    });
    a.createObjectStore("FileEntities", {
        keyPath: "id"
    }).createIndex("DocIdEntityTypeIndex", "docIdEntityTypeIndex")
}
;
v.K = function() {
    Ki(this.V, this.ab, this.Ea, this.Rb, this.Hc, this.I, this.S, this.F, this.fa);
    mu.prototype.K.call(this)
}
;
"ApplicationMetadata Comments DocumentCommandsMetadataStaging DocumentCommandsMetadata DocumentCommandsStaging DocumentCommands DocumentEntities DocumentLocks Documents FileEntities FontMetadata Impressions NewDocumentIds PendingQueueCommands PendingQueues ProfileData SyncObjects Users".split(" ").sort(function(a, c) {
    return a > c ? 1 : a < c ? -1 : 0
});
function Au(a, c, d) {
    this.g = !1;
    this.j = d
}
y(Au, Al);
Au.prototype.ha = function() {
    return ["BlobMetadata"]
}
;
Au.prototype.ea = function(a, c) {
    c = Z(c, "BlobMetadata");
    switch (a.getType()) {
    case "update-record":
        a.ja ? c.add(a.Y) : rt(this.j, V(a), a.Y, c);
        break;
    case "delete-record":
        Cs(c, V(a));
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function Bu(a, c, d, e, f, g) {
    tt.call(this, a, c, d, e, f, g)
}
y(Bu, tt);
Bu.prototype.ha = function(a) {
    var c = tt.prototype.ha.call(this, a);
    "delete-record" == a.getType() && c.push("BlobMetadata");
    return c
}
;
Bu.prototype.o = function(a, c) {
    tt.prototype.o.call(this, a, c);
    a = V(a);
    Cs(Z(c, "BlobMetadata"), [a], [a, []])
}
;
function Cu() {}
y(Cu, Et);
Cu.prototype.g = function(a, c, d, e, f, g) {
    return new Bu(a,c,d,e,f,g)
}
;
function Du(a, c, d, e, f, g, h, k, l) {
    h = void 0 === h ? new Cu : h;
    zu.call(this, a, c, d, e, f, g, h, k, l);
    this.Jc = new Au(this.j,this.A,this.o,g);
    Wl(this, this.Jc)
}
y(Du, zu);
Du.prototype.qb = aa(7);
Du.prototype.Tb = aa(!0);
Du.prototype.nb = function(a) {
    zu.prototype.nb.call(this, a);
    Eu(a)
}
;
Du.prototype.Xb = function(a) {
    Eu(a)
}
;
function Eu(a) {
    a.db.createObjectStore("BlobMetadata", {
        keyPath: ["d", "p"]
    })
}
;function Fu(a, c, d, e) {
    qm.call(this, a, c);
    new tk(c,e)
}
y(Fu, qm);
Fu.prototype.ea = function(a, c) {
    switch (a.getType()) {
    case "append-template-commands":
        c = Z(c, "TemplateCommands");
        a.A && Cs(c, [a.j], [a.j, []]);
        for (var d = a.o, e = 0; e < d.length; ++e) {
            for (var f = c, g = a.j, h = d[e], k = h.j, l = [], m = 0; m < k.length; ++m)
                l.push(this.o.Z(k[m]));
            f.put(Ks(g, h.o, h.v, h.g, h.A, l).g)
        }
        break;
    default:
        throw Error("mb`" + a.getType());
    }
}
;
function Gu(a, c, d, e) {
    rm.call(this, d, e);
    this.j = new iu
}
y(Gu, rm);
Gu.prototype.ha = function() {
    return ["TemplateCommands", "TemplateCreationMetadata", "TemplateMetadata"]
}
;
Gu.prototype.ea = function(a, c) {
    var d = a.o;
    switch (d) {
    case "templateMetadata":
        d = "TemplateMetadata";
        break;
    case "templateCreationMetadata":
        d = "TemplateCreationMetadata";
        break;
    default:
        throw Error("Zb`" + d);
    }
    d = Z(c, d);
    switch (a.getType()) {
    case "update-record":
        a.ja ? d.put(a.Y) : rt(this.j, V(a), a.Y, d);
        break;
    case "delete-record":
        Cs(d, V(a));
        break;
    case "append-template-commands":
        this.Ia(a.Ja()).ea(a, c);
        break;
    default:
        throw Error("Ib`" + a.getType());
    }
}
;
function Hu(a, c, d, e, f, g, h, k, l, m) {
    Du.call(this, a, c, e, f, g, k, void 0, l, m);
    a = ["kix", "punch", "ritz"];
    c = this.j;
    if (!d)
        for (d = {},
        e = new jj,
        f = 0; f < a.length; f++)
            d[a[f]] = new Fu(a[f],e,c,h);
    this.Fa = new Gu(c,this.A,d,k);
    Wl(this, this.Fa)
}
y(Hu, Du);
v = Hu.prototype;
v.qb = aa(8);
v.hc = q("Fa");
v.Tb = aa(!0);
v.nb = function(a) {
    Du.prototype.nb.call(this, a);
    Iu(a)
}
;
v.Xb = function(a) {
    var c = a.db;
    Tc(c.objectStoreNames, "DocumentCommandsStaging") && c.deleteObjectStore("DocumentCommandsStaging");
    Tc(c.objectStoreNames, "DocumentCommandsMetadata") && c.deleteObjectStore("DocumentCommandsMetadata");
    Tc(c.objectStoreNames, "DocumentCommandsMetadataStaging") && c.deleteObjectStore("DocumentCommandsMetadataStaging");
    Iu(a)
}
;
function Iu(a) {
    a = a.db;
    a.createObjectStore("TemplateMetadata", {
        keyPath: ["id"]
    });
    a.createObjectStore("TemplateCreationMetadata", {
        keyPath: ["id"]
    });
    a.createObjectStore("TemplateCommands", {
        keyPath: "dcKey"
    })
}
;function Ju(a, c, d, e, f, g, h, k, l, m, p, r, u, w, F, L) {
    w = void 0 === w ? !1 : w;
    F = void 0 === F ? null : F;
    Q.call(this);
    this.v = a;
    this.ab = c;
    this.fa = d;
    this.P = e;
    this.oa = k;
    this.V = f;
    this.F = l;
    this.S = g;
    this.Fa = w;
    this.g = F;
    this.j = {};
    this.o = {};
    this.D = -1;
    this.A = new Xh;
    this.O = !1;
    this.H = h;
    this.lb = p;
    this.M = r;
    this.J = u;
    this.W = L;
    this.B = m
}
y(Ju, Q);
function Ku(a, c) {
    var d = c.qb();
    a.D = Math.max(a.D, d);
    a.j[d] = c
}
Ju.prototype.create = function(a, c) {
    var d = this;
    if (this.O)
        throw Error("$b");
    this.O = !0;
    if (isNaN(this.V))
        throw Error("ac");
    if (this.g)
        Lu(this, this.g);
    else {
        if (!ed)
            throw Error("bc");
        ot(function(e) {
            return Lu(d, e)
        }, a, this.v, function(e) {
            Gi(e.N, {
                databaseOpenFailure: "true"
            });
            ai(d.A, e);
            Mu(d)
        }, this.Fa, this.oa, this.F, this.B, c || void 0)
    }
    return this.A
}
;
function Lu(a, c) {
    a.g = c;
    if (a.P)
        for (var d = a.P(c, a.F), e = 0; e < d.length; e++)
            for (var f = a, g = d[e], h = g.Fc, k = g.Ja(), l = g.jd; l <= h; ++l) {
                var m = f.o[l];
                m || (m = f.o[l] = {});
                m[k] = g
            }
    d = new Ot(a.ab,a.fa,c,a.v,a.B,void 0,a.W);
    -1 == a.D && (Ku(a, new zu(c,a.o[6] || {},d,a.v,a.H,a.B,void 0,a.M,a.J)),
    Ku(a, new Du(c,a.o[7] || {},d,a.v,a.H,a.B,a.lb,a.M,a.J)),
    Ku(a, new Hu(c,a.o[8] || {},null,d,a.v,a.H,a.F,a.B,a.M,a.J)));
    Nu(a)
}
function Nu(a) {
    var c = Math.min(a.V, a.D)
      , d = Ou(a);
    !a.S && 0 >= d ? Pu(a, new Qk(4,"Schema initialization cannot be performed when schema updates are prevented.")) : !a.S || d >= c ? a.I() : Qu(a, d, c) ? Ru(a, d + 1, c, A(a.I, a, null), function(e) {
        ai(a.A, e);
        Mu(a)
    }) : pu(a.j[c], function() {
        return a.I()
    }, function(e) {
        return Pu(a, e)
    })
}
function Pu(a, c) {
    ai(a.A, c);
    Mu(a)
}
function Qu(a, c, d) {
    for (c += 1; c <= d; ++c)
        if (null == a.j[c] || !a.j[c].Tb())
            return !1;
    return !0
}
function Ru(a, c, d, e, f) {
    ru(a.j[c], A(a.Ea, a, c, d, e, f), f)
}
Ju.prototype.Ea = function(a, c, d, e) {
    a = Ou(this);
    a == c ? d() : Ru(this, a + 1, c, d, e)
}
;
Ju.prototype.I = function() {
    var a = Ou(this);
    if (a = this.j[a]) {
        a = new ul(a);
        this.g && Wh(a, this.g);
        for (var c in this.j)
            Wh(a, this.j[c]);
        for (var d in this.o) {
            c = this.o[d];
            for (var e in c)
                Wh(a, c[e])
        }
        Yh(this.A, a)
    } else
        this.v.info(Error("cc`" + (this.g ? lt(this.g) : -1))),
        Yh(this.A, null)
}
;
function Ou(a) {
    var c = a.g ? lt(a.g) : -1;
    1 < c && 6 > c && a.v.info(Error("dc`" + c));
    return 6 > c ? -1 : c
}
function Mu(a) {
    for (var c in a.j)
        a.j[c].X();
    for (var d in a.o) {
        c = a.o[d];
        for (var e in c)
            c[e].X()
    }
    Ji(a.g)
}
;function Su(a, c) {
    this.g = a;
    this.j = c
}
;function Tu(a, c, d, e, f, g, h, k) {
    Q.call(this);
    this.F = a;
    this.A = c;
    this.o = d;
    this.H = e;
    this.I = g ? g : "DefaultLocalStoreSessionId";
    this.J = h || new jj;
    this.B = f;
    this.D = !!k;
    this.j = null;
    this.v = new Uj;
    R(this, this.v);
    this.g = Uu(this)
}
y(Tu, Q);
function Uu(a) {
    a.g && Ji(a.g);
    var c = Fj(a.o, "lssv");
    return new Ju(a.F,a.I,0,a.Mc.bind(a),c,!0,new Nt,a.H,a.B,a.o)
}
function Vu(a) {
    if (a.j)
        return a.j;
    a.j = Wu(a);
    return a.j.Aa(function(c) {
        a.Kb();
        throw c;
    })
}
function ps(a) {
    return Vu(a).then(function(c) {
        return (new dh(function(d, e) {
            lu(c.rb(), d, e)
        }
        )).then(function(d) {
            return Xu(a, d) ? new Su(c,d[0]) : null
        })
    })
}
function Yu(a) {
    return Vu(a).then(function(c) {
        return (new dh(function(d, e) {
            lu(c.rb(), d, e)
        }
        )).then(function(d) {
            if (!Xu(a, d))
                throw d = {
                    usersLength: d.length,
                    allowNonOfflineEnabledUser: a.D,
                    storedUserMatchesFlag: 0 == d.length ? "no users" : d[0].R() == T(a.o, "docs-offline-lsuid")
                },
                Gi(Error("ec"), d);
            return new Su(c,d[0])
        })
    })
}
function Xu(a, c) {
    return 1 == c.length && (a.D || c[0].R() == T(a.o, "docs-offline-lsuid"))
}
v = Tu.prototype;
v.get = function() {
    return Yu(this).then(function(a) {
        return a.g
    })
}
;
function Wu(a) {
    return (new dh(function(c, d) {
        Th(a.g.create(a.Kb.bind(a)), c, d)
    }
    )).then(a.cd.bind(a))
}
v.cd = function(a) {
    var c = this;
    if (!a)
        throw Error("fc");
    if (this.A) {
        var d = new ws(a,this.A);
        R(this, d)
    }
    vl(a);
    Vj(this.v, a.j.j.D, function() {
        c.Kb()
    });
    Vj(this.v, a.j.W, function() {
        c.Kb()
    });
    return a
}
;
v.Kb = function() {
    Ji(this.g);
    this.g = Uu(this);
    this.j = null
}
;
v.Mc = function(a) {
    var c = this.J
      , d = this.B
      , e = new Ls("kix",6,8,c,a,d)
      , f = new Ls("punch",6,8,c,a,d)
      , g = new Ls("ritz",6,8,c,a,d);
    a = new Ls("drawing",6,8,c,a,d);
    return [g, e, f, a]
}
;
v.K = function() {
    Ji(this.g);
    Q.prototype.K.call(this)
}
;
function Zu(a, c, d) {
    this.j = a;
    this.A = d;
    this.o = "";
    this.g = void 0;
    this.M = {};
    this.B = 3;
    this.v = rg;
    this.L = !1;
    this.J = qg;
    this.C = !1;
    this.D = rg;
    this.F = -1;
    this.H = !1
}
function wr(a, c) {
    var d = [a.j];
    Wc(d, c);
    a.j = ri.apply(null, d)
}
function $u(a, c) {
    a.g = c;
    return a
}
function xr(a, c) {
    c = ug(c, function(d) {
        return "string" === typeof d ? d : JSON.stringify(d)
    });
    return $u(a, qi(c))
}
function yr(a, c) {
    a.v = c;
    a.L = !1;
    return a
}
function zr(a, c) {
    a.D = c;
    return a
}
Zu.prototype.setTimeout = function(a) {
    this.F = a;
    return this
}
;
Zu.prototype.withCredentials = function() {
    this.H = !0;
    return this
}
;
function Ar(a) {
    var c = av(a);
    if (!a.I)
        throw Error("lc`" + a.ca());
    a.I.send(c)
}
Zu.prototype.validate = n();
function bv(a) {
    var c = a.o;
    T(a.A, "docs-ucd");
    return c
}
Zu.prototype.ca = function() {
    return bv(this) + this.j
}
;
function cv(a) {
    if (Array.isArray(a.g)) {
        var c = a.g;
        try {
            if (S(a.A, "docs-net-cbfd") && z.FormData) {
                for (var d = new z.FormData, e = 0; e < c.length; e += 2)
                    d.append(c[e], c[e + 1]);
                var f = d
            } else
                f = pi(c);
            return f
        } catch (g) {
            if (g instanceof URIError && "URI malformed" == g.message) {
                f = [];
                for (d = 1; d < c.length; d += 2)
                    e = Pl("" + c[d]),
                    f = f.concat(e);
                c = "{" + C(f.join("; ")) + "}";
                a = a.ca().substr(0, 100);
                throw Gi(g, {
                    illegal_request_content: c,
                    request_uri: a
                });
            }
            throw Gi(g, {
                "docs-origin-class": "docs.net.AbstractRequestBuilder"
            });
        }
    }
    return a.g
}
"function" === typeof Blob && Blob.prototype.hasOwnProperty("size");
function dv(a) {
    this.g = a ? zg(a) : {};
    this.j = null
}
dv.prototype.Ca = function() {
    return this.g.token || null
}
;
function ev(a, c, d, e) {
    Y.call(this);
    this.v = e ? zg(e) : fv;
    this.o = "";
    d || (d = a.get("info_params"),
    "string" === typeof d ? a = JSON.parse(d) : (d = {},
    Ej(a, "info_params") ? (a = a.get("info_params"),
    a = null != a ? a : d) : a = d),
    d = a,
    a = ug(d, String),
    (e = (e = z._docs_coldstart_url) ? Bn(e).resourcekey : null) ? a.resourcekey = e : d.resourcekey && (d = jf(new eg(d.resourcekey), 2),
    null != d && (a.resourcekey = d)),
    d = new dv(a));
    this.g = d;
    (c = wi((c || z).location.href, "authkey")) && gv(this, "authkey", c)
}
y(ev, Y);
function gv(a, c, d) {
    var e = a.g;
    if (d) {
        if (e.g[c] = d,
        e.j && (c = e.Ca()))
            e.j.qa(c),
            e.j = null
    } else
        delete e.g[c];
    a.dispatchEvent("l")
}
function hv(a, c) {
    a.g.g.at && gv(a, "at", c);
    gv(a, "token", c)
}
ev.prototype.Ca = function() {
    return this.g.Ca()
}
;
var iv = new function() {
    this.g = {};
    this.g["X-Same-Domain"] = "1"
}
  , fv = zg(iv.g);
function jv(a) {
    Y.call(this);
    var c = this;
    this.o = a;
    this.A = function(d) {
        gv(c.o, "tfe", d)
    }
    ;
    this.g = null;
    this.v = new np(this);
    qp(this.v, this.o, "l", this.B)
}
y(jv, Y);
jv.prototype.B = function() {
    this.g && this.g.A(this.o.g.g)
}
;
jv.prototype.K = function() {
    this.g && !this.g.wa() && (this.g.j("tfe_changed", this.A),
    this.g.g(),
    this.g.C());
    this.g = null;
    Ji(this.v);
    Y.prototype.K.call(this)
}
;
function kv(a, c) {
    Q.call(this);
    this.j = [];
    this.A = a;
    (this.g = c || null) && R(this, this.g);
    this.o = this.v = null;
    this.g && (this.o = new jp(500),
    this.v = new np(this),
    qp(this.v, this.o, "tick", this.B))
}
y(kv, Q);
kv.prototype.reset = function() {
    this.j = [];
    this.o && this.o.stop()
}
;
kv.prototype.B = function() {
    for (; 0 < this.j.length && Gm(this.g); )
        Hm(this.g),
        this.A(this.j.shift());
    lv(this)
}
;
function lv(a) {
    0 == a.j.length && a.o && a.o.stop()
}
kv.prototype.K = function() {
    Ji(this.v);
    Ji(this.o);
    Q.prototype.K.call(this)
}
;
function mv(a, c) {
    Io.call(this, "m", a);
    this.g = c
}
y(mv, Io);
function nv(a, c, d, e, f, g, h, k, l, m, p, r, u, w, F, L, ra) {
    Y.call(this);
    this.P = a;
    this.Ea = c;
    this.H = d;
    this.o = e;
    this.J = w || (d ? "POST" : "GET");
    this.M = p;
    this.A = f;
    this.O = g;
    this.I = h;
    this.oa = k;
    this.S = l;
    this.fa = m;
    this.B = u;
    this.W = zg(F);
    this.Fa = L;
    this.v = new Wq(Bj(),ra)
}
y(nv, Y);
nv.prototype.ca = q("P");
nv.prototype.send = function(a) {
    Zq(this.v);
    ov(this, a)
}
;
nv.prototype.reset = n();
nv.prototype.K = function() {
    this.dispatchEvent("n");
    this.reset();
    delete this.I;
    delete this.O;
    delete this.A;
    Y.prototype.K.call(this)
}
;
function pv(a) {
    if ("text" == a.v && null != a.o && lc(a.o || "", ")]}'\n")) {
        try {
            var c = qv(a)
        } catch (d) {
            return null
        }
        if (Array.isArray(c) && (a = c[0],
        Array.isArray(a) && "er" == a[0]))
            return Kn(JSON.stringify(a))
    }
    return null
}
function rv(a) {
    a = pv(a);
    if (!a)
        return null;
    var c;
    return (a = null == (c = H(a, gg, 10)) ? void 0 : rf(c, hg)) ? a : null
}
;function sv(a, c, d, e, f, g, h, k, l, m, p) {
    Y.call(this);
    var r = this;
    this.O = c;
    this.H = m || null;
    this.v = new ev(c,d,g,k);
    R(this, this.v);
    this.A = p || new jv(this.v);
    R(this, this.A);
    this.D = new np(this);
    R(this, this.D);
    this.B = e || null;
    e && (this.B instanceof kq && (a = this.B,
    rq(a, new Sq(a.D,this.H))),
    qp(this.D, e, "b", this.bd));
    this.g = f || new ln;
    this.S = l || null;
    this.M = new Jq;
    R(this, this.M);
    this.o = [];
    this.J = [];
    this.I = new kv(function(u) {
        5 <= r.g.j.g || (r.g.j == (hn(),
        Tm) && on(r.g, (hn(),
        Um)),
        sp(r.D, u, "m", r.xc),
        u.send(r.v))
    }
    ,h);
    R(this, this.I);
    this.F = (hn(),
    an);
    this.P = new Uj;
    R(this, this.P);
    qp(this.D, this.A, "k", this.Yc)
}
y(sv, Y);
function vr(a, c) {
    c = new tv(a,c,a,a.O,a.S,!1);
    c.o = a.v.o;
    return c
}
v = sv.prototype;
v.send = function(a) {
    if (!a.wa()) {
        var c = this.o;
        Tc(c, a) || c.push(a);
        a: {
            c = this.I;
            if (c.g) {
                if (!Gm(c.g) || 0 != c.j.length) {
                    c.j.push(a);
                    c.o.start();
                    break a
                }
                Hm(c.g)
            }
            c.A(a)
        }
        sp(this.D, a, "n", this.dd)
    }
}
;
v.xc = function(a) {
    var c = a.target
      , d = a.g;
    "SOON" == d.C["x-restart"] && this.g.v.dispatchEvent(null);
    this.B && uv(d) && 1 != c.o && (c.ca().startsWith("/logImpressions") || c.ca().startsWith("/naLogImpressions") || this.B.log(Error("jc"), vv(d)));
    if (a = wv(d)) {
        var e = !0
          , f = !1;
        if ("e" == a.type) {
            try {
                c.O(d),
                xv(this, c)
            } catch (h) {
                a = new rr("h",a.C,a.g,function() {
                    return qv(d)
                }
                ),
                a.cause = h,
                a.j = "e",
                xv(this, c, this.F)
            }
            c.X()
        } else if ("f" == a.type || "g" == a.type)
            switch (yv(this, a, c, d)) {
            case 4:
                f = !0;
                a.j = a.type;
                a.type = "d";
                break;
            case 1:
                a.j = a.type;
                a.type = "d";
                break;
            case 3:
                e = !1
            }
        else
            "i" == a.type && (this.B && this.B.info(Error("ic")),
            xv(this, c, (hn(),
            $m)),
            e = !1);
        if ("d" == a.type) {
            try {
                if (c.I(a),
                0 == !c.oa && (e = !1),
                c.fa)
                    xv(this, c);
                else {
                    var g = c.S(a) || (f ? (hn(),
                    an) : nn(a.g, this.F));
                    xv(this, c, g)
                }
            } catch (h) {
                a = new rr("h",a.C,a.g,function() {
                    return qv(d)
                }
                ),
                a.cause = h,
                a.j = "d",
                xv(this, c, this.F)
            }
            c.X()
        }
        e && this.dispatchEvent(a)
    }
}
;
v.dd = function(a) {
    a = a.target;
    if (Tc(this.I.j, a)) {
        var c = this.I;
        Uc(c.j, a);
        lv(c)
    } else
        Tc(this.o, a) && (tp(this.D, a, "m", this.xc),
        xv(this, a));
    Uc(this.o, a);
    Uc(this.J, a)
}
;
function xv(a, c, d) {
    var e = a.g.j
      , f = e
      , g = d || (hn(),
    Wm);
    d = !d;
    Uc(a.o, c);
    Uc(a.J, c);
    hn();
    if (!(5 <= e.g))
        if (5 <= g.g)
            on(a.g, g, c.ca());
        else {
            var h = null != a.A.g || Sc(a.o, function(k) {
                return 3 == k.o
            });
            if (e == Um)
                d || !h ? 0 == a.o.length && (f = Tm) : (zv(a),
                f = g);
            else if (d)
                if (0 < a.o.length)
                    f = Vm,
                    Av(a);
                else {
                    if (null == a.A.g || a.A.g.o())
                        f = Tm
                }
            else
                f = g;
            on(a.g, f, c.ca())
        }
}
function yv(a, c, d, e) {
    var f = !1;
    if (200 == c.g) {
        var g = pv(e);
        if (g) {
            var h;
            g = We(g, gg, 10, !1);
            g || (g = gg[Gd],
            g || (g = new gg,
            Hd(g.G, 34),
            g = gg[Gd] = g));
            if (g = null == (h = rf(g, hg)) ? void 0 : h.Ca())
                hv(a.v, g),
                f = !0
        }
    }
    400 == c.g && (e = rv(e)) && e.Ca() && (hv(a.v, e.Ca()),
    f = !0);
    409 == c.g && gv(a.v, "tfe", null);
    e = 5 <= a.g.j.g;
    h = "g" == c.type;
    if (!e && f && 1 >= d.v.j)
        return Bv(a, d, 2),
        3;
    g = 0 === c.g ? 1 : 3;
    if (!e && 1 != d.o && 4 > d.v.j)
        return Bv(a, d, g),
        3;
    if (3 == d.o) {
        if (e)
            return 2;
        null == a.A.g || h ? Bv(a, d, g) : a.J.push(d)
    } else
        return f ? 4 : 1;
    zv(a);
    on(a.g, nn(c.g, a.F), d.ca());
    return 2
}
function zv(a) {
    null != a.A.g && 1 == a.g.j.g && (a = a.A,
    a.g.g(),
    a.g.v())
}
v.Ka = q("g");
function Bv(a, c, d) {
    d = Yq(c.v, d);
    a.M.Ga(function() {
        return a.send(c)
    }, d)
}
v.Yc = function(a) {
    var c = this.g.j;
    5 <= c.g || (a.j ? 1 != c.g && (0 < this.o.length ? (on(this.g, (hn(),
    Vm)),
    Av(this)) : on(this.g, (hn(),
    Tm))) : on(this.g, nn(a.g, this.F), null, a.g))
}
;
function Av(a) {
    var c = a.J.shift();
    c && a.send(c)
}
v.Ca = function() {
    return this.v.Ca()
}
;
v.bd = function() {
    var a = null != this.H && this.H.j() && this.H.g() ? (hn(),
    cn) : (hn(),
    bn);
    on(this.g, a)
}
;
v.K = function() {
    Ki(this.o);
    Y.prototype.K.call(this)
}
;
function Cv(a, c, d, e, f, g) {
    this.A = a;
    this.v = c;
    this.g = d;
    this.o = e;
    this.j = f;
    this.C = g
}
;function Dv(a, c, d, e, f, g, h) {
    this.o = a;
    this.v = c || "text";
    this.A = mc(Mg(d)) ? null : d;
    this.j = void 0 !== e ? e : 200;
    this.C = {};
    if (g)
        for (var k in g)
            this.C[k.toLowerCase()] = g[k];
    this.g = void 0 !== f ? f : 0;
    this.D = h || {};
    this.B = void 0
}
function Ev(a) {
    switch (a) {
    case "arraybuffer":
        return "arraybuffer";
    case "blob":
        return "blob";
    case "document":
        return "document";
    case "text":
        return "text";
    case "":
        return "text";
    default:
        throw Error("kc`" + a);
    }
}
Dv.prototype.Ua = function() {
    return 0 == this.g
}
;
function qv(a) {
    if (void 0 === a.B) {
        var c = a.o || "";
        kn();
        c = c.replace(jn, "");
        if (c)
            if ("null" === c)
                var d = null;
            else {
                for (var e = c.length, f = 0; f < e && 32 >= c.charCodeAt(f); )
                    f = f + 1 | 0;
                for (var g = e; g > f && 32 >= c.charCodeAt(g - 1 | 0); )
                    g = g - 1 | 0;
                c = 0 < f || g < e ? c.substr(f, g - f | 0) : c;
                try {
                    d = JSON.parse(c)
                } catch (h) {
                    a = Za(h);
                    if (a instanceof db)
                        throw d = new Ob,
                        c = "ia`" + C(a.g),
                        d.j = a,
                        d.g = c,
                        Wa(d),
                        Xa(d, Error(d)),
                        d.N;
                    throw a.N;
                }
                if (!(d instanceof Object))
                    throw qb().N;
            }
        else
            d = null;
        a.B = d
    }
    return a.B
}
function vv(a) {
    var c = a.j
      , d = a.g
      , e = a.v
      , f = a.A;
    if ("text" == a.v) {
        var g = a.o || "";
        g = -1 != g.indexOf("&") ? "document"in z ? Jg(g) : Lg(g) : g;
        50 < g.length && (g = g.substring(0, 47) + "...");
        vc.test(g) && (-1 != g.indexOf("&") && (g = g.replace(oc, "&amp;")),
        -1 != g.indexOf("<") && (g = g.replace(pc, "&lt;")),
        -1 != g.indexOf(">") && (g = g.replace(qc, "&gt;")),
        -1 != g.indexOf('"') && (g = g.replace(rc, "&quot;")),
        -1 != g.indexOf("'") && (g = g.replace(tc, "&#39;")),
        -1 != g.indexOf("\x00") && (g = g.replace(uc, "&#0;")));
        g += "   (truncated)"
    } else
        g = "responseObject";
    c = {
        RespStatus: c,
        RespErr: d,
        RespType: e,
        RespContentType: f,
        RespString: g
    };
    Bg(c, a.D);
    return c
}
function wv(a) {
    if ("NOW" == a.C["x-restart"])
        return new rr("i",a.g,a.j,function() {
            return qv(a)
        }
        );
    if (7 == a.g)
        return null;
    var c = Fv(a) ? "f" : Gv(a) ? "g" : a.Ua() ? "e" : "d";
    return new rr(c,a.g,a.j,function() {
        return qv(a)
    }
    ,6 == a.g && 500 == a.j ? pv(a) : null)
}
function Fv(a) {
    var c = a.g
      , d = a.j;
    return a.Ua() ? 0 != c || 0 != d || "text" == a.v && null != a.o ? !1 : !0 : 8 == c || 5 == c || 6 == c && (0 >= d || 503 == d || 405 == d) ? !0 : !1
}
function Gv(a) {
    var c = a.j;
    return 6 == a.g && (202 == c || 401 == c || 403 == c || 409 == c || 429 == c || 433 == c || 500 <= c && 599 >= c && 503 != c && 512 != c && 550 != c) || 400 == c && null != rv(a) ? !0 : 200 == c ? null == a.A || pv(a) ? !0 : uv(a) : !1
}
function uv(a) {
    if (200 == a.j && null != a.A && !pv(a) && "text" == a.v) {
        if (mc(Mg(a.o)))
            return !0;
        if (lc(a.o || "", ")]}'\n"))
            try {
                return null == qv(a)
            } catch (c) {}
    }
    return !1
}
;function Hv(a, c, d, e, f, g, h, k, l, m, p, r, u, w, F, L, ra, cb, Aa) {
    nv.call(this, a, c, d, e, f, g, h, k, l, m, p, r, u, w, F, L, Aa);
    this.Rb = ra;
    this.g = null;
    this.D = new np(this);
    this.F = 0;
    this.Qb = !!f;
    this.ab = cb
}
y(Hv, nv);
function ov(a, c) {
    a.g = a.Rb();
    rp(a.D, a.g, function() {
        var f = a.g;
        try {
            var g = "" == f.A ? aq(f) : bq(f)
        } catch (F) {
            g = ""
        }
        var h = f.A;
        try {
            if (f.g && f.Ma()) {
                var k = f.g.getResponseHeader("Content-Type");
                var l = null === k ? void 0 : k
            } else
                l = void 0;
            var m = l
        } catch (F) {
            m = null
        }
        var p = new Cv(g,h,m,f.Ka(),f.B,f.g && 2 <= $p(f) ? f.g.getAllResponseHeaders() || "" : "");
        f = {
            ReqUri: a.P,
            ReqContent: a.H,
            ReqMethod: a.J
        };
        m = p.A;
        l = Ev(p.v);
        k = p.g;
        g = p.o;
        h = p.j;
        var r = {};
        p = ha(p.C.split("\r\n"));
        for (var u = p.next(); !u.done; u = p.next())
            if (u = u.value,
            !mc(Mg(u))) {
                var w = u.indexOf(": ");
                -1 != w && (r[u.substr(0, w)] = u.substr(w + 2))
            }
        f = new Dv(m,l,k,g,h,r,f);
        a.reset();
        a.dispatchEvent(new mv(a,f))
    });
    a.Qb && qp(a.D, a.g, "readystatechange", function() {
        if (3 == $p(a.g) && a.g.Ua() && 200 == a.g.Ka()) {
            var f = aq(a.g);
            if (f.length > a.F) {
                var g = f.substring(a.F);
                a.F = f.length;
                a.A && a.A(g)
            }
        }
    });
    a.g.D = Math.max(0, a.B);
    "text" != a.M && (a.g.A = Iv(a.M));
    a.g.F = a.Fa;
    var d = si(a.Ea + a.ca(), c.g.g)
      , e = {};
    Bg(e, a.W, zg(c.v));
    a.ab && 0 < a.B && (e["X-Client-Deadline-Ms"] = a.B);
    a.g.send(d, a.J, a.H, e)
}
Hv.prototype.reset = function() {
    this.g && (this.g.X(),
    this.g = null)
}
;
Hv.prototype.K = function() {
    Ji(this.D);
    nv.prototype.K.call(this)
}
;
function Iv(a) {
    switch (a) {
    case "arraybuffer":
        return "arraybuffer";
    case "blob":
        return "blob";
    case "document":
        return "document";
    default:
        return ""
    }
}
;function tv(a, c, d, e, f, g) {
    Zu.call(this, c, d, e, f);
    this.I = a;
    this.P = !!g;
    this.O = S(e, "docs-ecdh")
}
y(tv, Zu);
function av(a) {
    var c = a.F;
    0 > c && (c = a.P ? 4E4 : 2E4);
    return new Hv(a.j,bv(a),cv(a),a.B,null,a.D,a.v,a.L,a.J,a.C,"text",!1,c,null,a.M,a.H,function() {
        return new Qp
    }
    ,a.O,void 0)
}
;function Jv(a, c) {
    tb.call(this, c);
    this.j = a
}
y(Jv, tb);
function Kv(a) {
    tb.call(this, "Binary not cached.");
    a = li(a);
    je(this, "serviceworker_fetchEvent_failReason", "binary_not_cached");
    je(this, "serviceworker_fetchUrl", Lv(a))
}
y(Kv, tb);
function Lv(a) {
    var c = a;
    0 <= ui(a, 0, "ouid", a.search(vi)) && wi(a, "ouid") && (c = ti(yi(c, "ouid"), "ouid", "{OUID}"));
    0 <= ui(a, 0, "key", a.search(vi)) && wi(a, "key") && (c = ti(yi(c, "key"), "key", "REDACTED"));
    return c
}
;function Mv(a) {
    return (a = a.exec(Ec())) ? a[1] : ""
}
var xc = function() {
    if ($c)
        return Mv(/Firefox\/([0-9.]+)/);
    if (ed) {
        if (Pc() || (Cc && Fc && Fc.platform ? "macOS" === Fc.platform : E("Macintosh"))) {
            var a = Mv(/CriOS\/([0-9.]+)/);
            if (a)
                return a
        }
        return Mv(/Chrome\/([0-9.]+)/)
    }
    if (fd && !Pc())
        return Mv(/Version\/([0-9.]+)/);
    if (ad || cd) {
        if (a = /Version\/(\S+).*Mobile\/(\S+)/.exec(Ec()))
            return a[1] + "." + a[2]
    } else if (dd)
        return (a = Mv(/Android\s+([0-9.]+)/)) ? a : Mv(/Version\/([0-9.]+)/);
    return ""
}();
function Nv(a) {
    Y.call(this);
    this.o = a;
    this.enabled = !1;
    this.v = function() {
        return Date.now()
    }
    ;
    this.A = this.v()
}
y(Nv, Y);
Nv.prototype.setInterval = function(a) {
    this.o = a;
    this.g && this.enabled ? (this.stop(),
    this.start()) : this.g && this.stop()
}
;
Nv.prototype.start = function() {
    var a = this;
    this.enabled = !0;
    this.g || (this.g = setTimeout(function() {
        Ov(a)
    }, this.o),
    this.A = this.v())
}
;
Nv.prototype.stop = function() {
    this.enabled = !1;
    this.g && (clearTimeout(this.g),
    this.g = void 0)
}
;
function Ov(a) {
    if (a.enabled) {
        var c = Math.max(a.v() - a.A, 0);
        c < .8 * a.o ? a.g = setTimeout(function() {
            Ov(a)
        }, a.o - c) : (a.g && (clearTimeout(a.g),
        a.g = void 0),
        a.dispatchEvent("tick"),
        a.enabled && (a.stop(),
        a.start()))
    } else
        a.g = void 0
}
;function Pv(a) {
    this.j = this.g = this.o = a
}
Pv.prototype.reset = function() {
    this.j = this.g = this.o
}
;
function Qv(a) {
    this.G = G(a)
}
y(Qv, O);
Qv.prototype.Zb = function() {
    return kf(this, 1)
}
;
function Rv(a) {
    this.G = G(a)
}
y(Rv, O);
function Sv(a) {
    this.G = G(a)
}
y(Sv, O);
function Tv(a, c) {
    ff(a, Rv, 1, c)
}
Sv.ia = [1];
function Uv(a) {
    this.G = G(a)
}
y(Uv, O);
var Vv = ["platform", "platformVersion", "architecture", "model", "uaFullVersion"]
  , Wv = new Sv
  , Xv = null;
function Yv(a, c) {
    c = void 0 === c ? Vv : c;
    if (!Xv) {
        var d;
        a = null == (d = a.navigator) ? void 0 : d.userAgentData;
        if (!a || "function" !== typeof a.getHighEntropyValues)
            return Promise.reject(Error("mc"));
        d = (a.brands || []).map(function(e) {
            var f = new Rv;
            f = M(f, 1, e.brand);
            return M(f, 2, e.version)
        });
        Tv(J(Wv, 2, a.mobile), d);
        Xv = a.getHighEntropyValues(c)
    }
    return Xv.then(function(e) {
        var f = sf(Wv);
        c.includes("platform") && M(f, 3, e.platform);
        c.includes("platformVersion") && M(f, 4, e.platformVersion);
        c.includes("architecture") && M(f, 5, e.architecture);
        c.includes("model") && M(f, 6, e.model);
        c.includes("uaFullVersion") && M(f, 7, e.uaFullVersion);
        return f
    }).catch(function() {
        return sf(Wv)
    })
}
;function Zv(a) {
    this.G = G(a)
}
y(Zv, O);
function $v(a) {
    this.G = G(a, 19)
}
y($v, O);
$v.prototype.wb = function(a) {
    return N(this, 2, a)
}
;
$v.ia = [3, 5];
function aw(a) {
    this.G = G(a, 7)
}
y(aw, O);
var bw = dg(aw);
aw.ia = [5, 6];
function cw(a) {
    this.G = G(a)
}
y(cw, O);
var dw = new uf(175237375,cw);
function hr(a) {
    Q.call(this);
    var c = this;
    this.j = [];
    this.O = "";
    this.P = this.J = -1;
    this.I = this.A = 0;
    this.S = 1;
    this.Mb = 0;
    this.gb = a.gb;
    this.pb = a.pb || n();
    this.v = new ew(a.gb,a.Ta);
    this.pa = a.pa;
    this.jb = a.jb || null;
    this.M = 1E3;
    this.B = a.sd || null;
    this.Va = a.Va || null;
    this.mb = a.mb || !1;
    this.ib = a.ib || null;
    this.withCredentials = !a.sc;
    this.Ta = a.Ta || !1;
    this.H = "undefined" !== typeof URLSearchParams && !!(new URL(fw())).searchParams && !!(new URL(fw())).searchParams.set;
    var d = N(new Zv, 1, 1);
    gw(this.v, d);
    this.o = new Pv(1E4);
    this.g = new Nv(this.o.g);
    a = hw(this, a.nc);
    Yo(this.g, "tick", a, !1, this);
    this.D = new Nv(6E5);
    Yo(this.D, "tick", a, !1, this);
    this.mb || this.D.start();
    this.Ta || (Yo(document, "visibilitychange", function() {
        "hidden" === document.visibilityState && c.F()
    }),
    Yo(document, "pagehide", this.F, !1, this))
}
y(hr, Q);
function hw(a, c) {
    return a.H ? c ? function() {
        c().then(function() {
            a.flush()
        })
    }
    : function() {
        a.flush()
    }
    : n()
}
hr.prototype.K = function() {
    this.F();
    this.g.stop();
    this.D.stop();
    Q.prototype.K.call(this)
}
;
function lr(a, c) {
    a.H && (c instanceof cr ? a.log(c) : (c = dr(new cr, c.Z()),
    a.log(c)))
}
hr.prototype.log = function(a) {
    if (this.H) {
        a = sf(a);
        var c = this.S++;
        a = K(a, 21, c);
        if (!hf(a)) {
            var d = Date.now();
            c = a;
            d = Number.isFinite(d) ? d.toString() : "0";
            Te(c, 1, te(d))
        }
        null != gf(a, 15) || K(a, 15, 60 * (new Date).getTimezoneOffset());
        c = this.j.length - this.M + 1;
        0 < c && (this.j.splice(0, c),
        this.A += c);
        this.j.push(a);
        this.mb || this.g.enabled || this.g.start()
    }
}
;
hr.prototype.flush = function(a, c) {
    var d = this;
    if (0 === this.j.length)
        a && a();
    else {
        var e = Date.now();
        if (this.P > e && this.J < e)
            c && c("throttled");
        else {
            this.pa && ("function" === typeof this.pa.Zb ? iw(this.v, this.pa.Zb()) : iw(this.v, 0));
            var f = jw(this.v, this.j, this.A, this.I, this.jb);
            e = {};
            var g = this.pb();
            g && (e.Authorization = g);
            this.B || (this.B = fw());
            try {
                var h = (new URL(this.B)).toString()
            } catch (l) {
                h = (new URL(this.B,window.location.origin)).toString()
            }
            h = new URL(h);
            this.Va && (e["X-Goog-AuthUser"] = this.Va,
            h.searchParams.set("authuser", this.Va));
            this.ib && (e["X-Goog-PageId"] = this.ib,
            h.searchParams.set("pageId", this.ib));
            if (g && this.O === g)
                c && c("stale-auth-token");
            else {
                this.j = [];
                this.g.enabled && this.g.stop();
                this.A = 0;
                var k = f.Z();
                e = {
                    url: h.toString(),
                    body: k,
                    ae: 1,
                    md: e,
                    nd: "POST",
                    withCredentials: this.withCredentials,
                    Mb: this.Mb
                };
                h = function(l) {
                    d.o.reset();
                    d.g.setInterval(d.o.g);
                    if (l) {
                        var m = null;
                        try {
                            var p = JSON.stringify(JSON.parse(l.replace(")]}'\n", "")));
                            m = bw(p)
                        } catch (r) {}
                        m && (l = Number,
                        p = "-1",
                        p = void 0 === p ? "0" : p,
                        p = lf(hf(m), p),
                        l = l(p),
                        0 < l && (d.J = Date.now(),
                        d.P = d.J + l),
                        m = rf(m, dw)) && (m = nf(m, 1, -1),
                        -1 !== m && (d.o = new Pv(1 > m ? 1 : m),
                        d.g.setInterval(d.o.g)))
                    }
                    a && a();
                    d.I = 0
                }
                ;
                k = function(l, m) {
                    var p = ef(f, cr, 3);
                    var r = gf(f, 14)
                      , u = d.o;
                    u.j = Math.min(3E5, 2 * u.j);
                    u.g = Math.min(3E5, u.j + Math.round(.2 * (Math.random() - .5) * u.j));
                    d.g.setInterval(d.o.g);
                    401 === l && g && (d.O = g);
                    r && (d.A += r);
                    void 0 === m && (m = 500 <= l && 600 > l || 401 === l || 0 === l);
                    m && (d.j = p.concat(d.j),
                    d.mb || d.g.enabled || d.g.start());
                    c && c("net-send-failed", l);
                    ++d.I
                }
                ;
                d.pa && d.pa.send(e, h, k)
            }
        }
    }
}
;
hr.prototype.F = function() {
    kw(this.v, !0);
    this.flush();
    kw(this.v, !1)
}
;
function fw() {
    return "https://play.google.com/log?format=json&hasfast=true"
}
function ew(a, c) {
    this.Ta = c = void 0 === c ? !1 : c;
    this.j = this.locale = null;
    this.g = new $v;
    Number.isInteger(a) && this.g.wb(a);
    c || (this.locale = document.documentElement.getAttribute("lang"));
    gw(this, new Zv)
}
ew.prototype.wb = function(a) {
    this.g.wb(a);
    return this
}
;
function gw(a, c) {
    I(a.g, Zv, 1, c);
    kf(c, 1) || N(c, 1, 1);
    a.Ta || (c = lw(a),
    jf(c, 5) || M(c, 5, a.locale));
    a.j && (c = lw(a),
    H(c, Sv, 9) || I(c, Sv, 9, a.j))
}
function iw(a, c) {
    Ve(mw(a), Uv, 11) && (a = nw(a),
    N(a, 1, c))
}
function kw(a, c) {
    Ve(mw(a), Uv, 11) && (a = nw(a),
    J(a, 2, c))
}
function mw(a) {
    return H(a.g, Zv, 1)
}
function ir(a) {
    var c = void 0 === c ? Vv : c;
    var d = a.Ta ? void 0 : window;
    d ? Yv(d, c).then(function(e) {
        a.j = e;
        e = lw(a);
        I(e, Sv, 9, a.j);
        return !0
    }).catch(aa(!1)) : Promise.resolve(!1)
}
function lw(a) {
    a = mw(a);
    var c = H(a, Uv, 11);
    c || (c = new Uv,
    I(a, Uv, 11, c));
    return c
}
function nw(a) {
    a = lw(a);
    var c = H(a, Qv, 10);
    c || (c = new Qv,
    J(c, 2, !1),
    I(a, Qv, 10, c));
    return c
}
function jw(a, c, d, e, f) {
    var g = 0
      , h = 0;
    d = void 0 === d ? 0 : d;
    g = void 0 === g ? 0 : g;
    h = void 0 === h ? 0 : h;
    e = void 0 === e ? 0 : e;
    if (Ve(mw(a), Uv, 11)) {
        var k = nw(a);
        qf(k, 3, e)
    }
    Ve(mw(a), Uv, 11) && (e = nw(a),
    qf(e, 4, g));
    Ve(mw(a), Uv, 11) && (g = nw(a),
    qf(g, 5, h));
    a = sf(a.g);
    a = Te(a, 4, te(Date.now().toString()));
    c = ff(a, cr, 3, c);
    f && (a = new $q,
    f = qf(a, 13, f),
    a = new ar,
    f = I(a, $q, 2, f),
    a = new br,
    f = I(a, ar, 1, f),
    f = N(f, 2, 9),
    I(c, br, 18, f));
    d && K(c, 14, d);
    return c
}
;function ow() {}
ow.prototype.send = function(a, c, d) {
    c = void 0 === c ? n() : c;
    d = void 0 === d ? n() : d;
    Up(a.url, function(e) {
        e = e.target;
        e.Ua() ? c(aq(e)) : d(e.Ka())
    }, a.nd, a.body, a.md, a.Mb, a.withCredentials)
}
;
ow.prototype.Zb = aa(1);
function gr(a, c) {
    Q.call(this);
    this.gb = a;
    this.Va = c;
    this.j = this.g = !1;
    this.jb = null;
    this.pa = new ow
}
y(gr, Q);
gr.prototype.sc = function() {
    this.o = !0;
    return this
}
;
function pw(a, c) {
    this.g = [];
    this.o = [];
    this.v = [];
    this.A = [];
    this.B = void 0 === a ? null : a;
    this.C = void 0 === c ? null : c
}
function qw(a, c, d, e) {
    a.g.push(new rw(c,d,e))
}
function sw(a) {
    var c = ["/"];
    c.every(function(d) {
        return lc(d, "/")
    });
    Wc(a.v, c)
}
function tw(a) {
    var c = uw;
    c.every(function(d) {
        return lc(d, "/")
    });
    Wc(a.o, c)
}
function vw(a) {
    var c = ["/offline/blank"];
    c.every(function(d) {
        return lc(d, "/")
    });
    Wc(a.A, c)
}
function ww(a, c) {
    for (var d = 0; d < a.g.length; d++)
        if (Tc(a.g[d].o, c))
            return a.g[d];
    return Tc(a.o, c) ? xw(a, 3) : null
}
function yw(a, c, d) {
    if (void 0 !== d) {
        d = ww(a, d);
        if (!d)
            throw Error("nc");
        if (Qc(sk, c) >= Qc(sk, d.j))
            return d.g
    }
    a = xw(a, c);
    if (!a)
        throw Error("oc");
    return a.g
}
pw.prototype.j = function(a) {
    return this.g.some(function(c) {
        return c.g == a
    }) || Tc(this.A, a)
}
;
function xw(a, c) {
    c = Qc(sk, c);
    if (-1 == c)
        throw Error("pc");
    for (; 0 <= c; c--)
        for (var d = 0; d < a.g.length; d++)
            if (a.g[d].j == sk[c])
                return a.g[d];
    return null
}
function rw(a, c, d) {
    this.o = a;
    this.g = c;
    this.j = d
}
;function zw(a, c, d, e, f, g, h) {
    this.ya = a;
    this.g = c || null;
    this.Pa = d || "";
    this.Ob = !!e;
    this.kc = !!f;
    this.j = !!g;
    this.o = null == this.g;
    this.v = !(!d && !e);
    this.A = h || null
}
;function Aw(a, c) {
    this.o = a;
    this.g = [a];
    c && (this.g = this.g.concat(c))
}
function Bw(a, c) {
    return a.g.some(function(d) {
        return !!ww(d, c)
    })
}
function Cw(a, c) {
    return a.g.some(function(d) {
        return Tc(d.o, c)
    })
}
function Dw(a, c) {
    return a.g.some(function(d) {
        return Tc(d.v, c)
    })
}
Aw.prototype.j = function(a) {
    return this.g.some(function(c) {
        return c.j(a)
    })
}
;
function Ew(a) {
    this.g = a
}
Ew.prototype.ob = function(a) {
    var c = Array.from(this.g.values()).map(function(e) {
        return e.ob(a)
    })
      , d = new bo(a);
    c.push(Fw(d));
    c.push(Gw(d));
    c.push(Hw(d));
    c = c.filter(function(e) {
        return !!e
    });
    return 0 == c.length ? null : c[0]
}
;
function Fw(a) {
    var c = In(Fn(a.o))
      , d = a.g.get("usp");
    return (a = "/open" === c ? a.g.get("id") : null) ? new zw("/edit","unknown",a,!1,!1,!1,d) : null
}
function Gw(a) {
    var c = In(Fn(a.o));
    a = a.g.get("usp");
    return (c = Iw[c]) ? new zw("/",c,void 0,!1,!0,!1,a) : null
}
function Hw(a) {
    var c = a.g.get("usp");
    return "/create" === a.o ? new zw("/create","kix",void 0,!0,!1,!1,c) : null
}
var Iw = {
    "": "kix",
    "/": "kix",
    "/docs": "kix",
    "/sheets": "ritz",
    "/slides": "punch"
};
function Jw(a, c, d, e, f, g) {
    this.A = a;
    this.Ya = c;
    this.g = d;
    this.o = e;
    this.j = g;
    this.v = f
}
Jw.prototype.getType = q("A");
function Kw(a, c, d, e, f) {
    return Lw(a, c, d, a.g.o.C, e, f)
}
function Mw(a, c, d, e, f, g, h) {
    a = Kw(a, c, d, e, f);
    c = {};
    c.ouri = g;
    c.et = 2;
    c.id = h;
    return Dn(a, c)
}
function Nw(a, c, d, e, f) {
    var g = ji(a.Ya)
      , h = g[5];
    c && a.o && (h += "/d/" + c);
    var k = S(a.v, "docs-erkpp");
    null != e && k && (h += "/r/" + e);
    h += d ? d : "/edit";
    d = {};
    c && !a.o && (d.id = c);
    null == e || k || (d.resourcekey = e);
    null != f && (d.usp = f);
    a = yg(d) ? null : qi(d);
    return hi(g[1], g[2], g[3], g[4], h, a)
}
function Ow(a, c) {
    if (!c)
        return null;
    c = In(Fn(ki(ji(c)[5] || null) || ""));
    a = ki(ji(a.Ya)[5] || null) || "/";
    if (!lc(c, a))
        return null;
    a = c.substring(a.length);
    return lc(a, "/") ? a : "/" + a
}
Jw.prototype.ob = function(a) {
    var c = Ow(this, a);
    if (!c)
        return null;
    var d = this.getType()
      , e = wi(a, "usp");
    if (Cw(this.g, c))
        return new zw(c,d,void 0,!0,!1,!1,e);
    if (Dw(this.g, c))
        return new zw(c,d,void 0,!1,!0,!1,e);
    if (this.g.o.B == c)
        return new zw(c,d,void 0,!1,!0,!0);
    if (this.g.o.C == c)
        return new zw(c,d,void 0,!1,!1,!0);
    if (this.g.j(c))
        return a = (a = Bn(a)) && a.id ? a.id : void 0,
        new zw(c,d,a,!1,!1,!0);
    e = new bo(a);
    a = e.g.get("usp");
    if (lc(c, "/d/")) {
        e = c.indexOf("/", 3);
        0 > e && (c += "/",
        e = c.indexOf("/", 3));
        var f = c.substring(3, e);
        c = c.substring(e);
        lc(c, "/r/") && (e = c.indexOf("/", 3),
        c = 0 > e ? "/" : c.substring(e));
        d = new zw(c,d,f,!1,!1,!1,a)
    } else
        d = (e = e.g.get("id")) ? new zw(c,d,e,!1,!1,!1,a) : null;
    return d && Bw(this.g, d.ya) ? d : null
}
;
function Lw(a, c, d, e, f, g) {
    a = zi(a.Ya, e);
    e = [];
    g && e.push("ouid=" + encodeURIComponent(String(g)));
    e.push("forcehl=1");
    e.push("hl=" + encodeURIComponent(String(f)));
    c && e.push("jobset=" + c);
    yo() && e.push("Debug=true");
    d && e.push("ftrack=1");
    return a += "?" + e.join("&")
}
;var uw = ["/create"]
  , Pw = "/comment /edit /htmlview /preview /view /".split(" ");
function Qw(a) {
    var c = new pw("/offline/hs","/offline/error");
    qw(c, Pw, "/offline/edit", 2);
    qw(c, [], "/offline/view", 1);
    qw(c, [], "/offline/comment", 4);
    qw(c, [], "/offline/viewcomments", 5);
    sw(c);
    tw(c);
    c = new Aw(c);
    return new Jw("kix",T(a, "kixOfflineUrl"),c,S(a, "udurls"),a)
}
function Rw(a) {
    var c = new pw(void 0,"/offline/error");
    qw(c, Pw, "/offline/edit", 2);
    qw(c, [], "/offline/view", 1);
    qw(c, [], "/offline/comment", 4);
    qw(c, [], "/offline/viewcomments", 5);
    tw(c);
    c = new Aw(c);
    return new Jw("drawing",T(a, "drawingsOfflineUrl"),c,S(a, "udurls"),a)
}
function Sw(a) {
    var c = new pw("/offline/hs","/offline/error");
    qw(c, Pw, "/offline/edit", 2);
    qw(c, [], "/offline/view", 1);
    qw(c, [], "/offline/comment", 4);
    qw(c, [], "/offline/viewcomments", 5);
    tw(c);
    sw(c);
    var d = new pw;
    qw(d, ["/localpresent"], "/offline/localpresent", 1);
    c = new Aw(c,[d]);
    return new Jw("punch",T(a, "punchOfflineUrl"),c,S(a, "udurls"),a)
}
function Tw(a) {
    var c = new pw("/offline/hs","/offline/error");
    qw(c, Pw, "/offline/edit", 2);
    qw(c, [], "/offline/view", 1);
    qw(c, [], "/offline/comment", 4);
    qw(c, [], "/offline/viewcomments", 5);
    tw(c);
    sw(c);
    vw(c);
    c = new Aw(c);
    return new Jw("ritz",T(a, "ritzOfflineUrl"),c,S(a, "udurls"),a,function(d) {
        return {
            dl: d.docLocale
        }
    }
    )
}
function Uw(a) {
    var c = [];
    c.push(Qw(a));
    c.push(Rw(a));
    c.push(Sw(a));
    c.push(Tw(a));
    return new Map(c.map(function(d) {
        return [d.getType(), d]
    }))
}
;function Vw(a, c, d) {
    this.g = a;
    this.o = c;
    this.v = ed;
    this.j = d
}
function Ww(a, c, d, e, f, g, h) {
    var k = d.R();
    var l = qk(c, "acjf", k);
    null != l ? k = $i(l) : (k = qk(c, "acl", k),
    k = rk(null != k ? Kb(k) : 0));
    k = !0 === Ye(k, 6) && !0 === Ye(k, 4) ? 3 : !0 === Ye(k, 4) ? 2 : !0 === Ye(k, 3) ? 4 : !0 === Ye(k, 2) ? 5 : !0 === Ye(k, 1) ? 1 : 0;
    a.v || (k = 1);
    l = Jk(c);
    switch (e) {
    case 0:
        var m = z.location.href;
        break;
    case 1:
        if (void 0 === f)
            throw Error("rc");
        m = Nw(Xw(a, l.getType()), c.R(), f, ik(c, "resourceKey"), h);
        break;
    case 3:
        m = Bn(z.window.location.href).turl || "";
        break;
    case 4:
        m = g;
        break;
    default:
        m = Nw(Xw(a, l.getType()), c.R(), void 0, ik(c, "resourceKey"), h)
    }
    e = Xw(a, l.getType());
    g = a.g;
    h = k;
    a = m;
    d = d.R();
    a: {
        k = e.g;
        if (void 0 !== f) {
            for (l = 0; l < k.g.length; l++)
                if (m = k.g[l],
                ww(m, f)) {
                    f = yw(m, h, f);
                    break a
                }
            throw Error("qc");
        }
        f = yw(k.o, h)
    }
    h = Jk(c);
    f = Lw(e, h.sa(), h.g, f, g, d);
    d = {};
    g = window;
    "true" != wi(g.location.href, "Debug") && "true" != wi(g.location.href, "debug") || (d.Debug = "true");
    d.id = c.R();
    (g = (g = kk(c, "docosKeyData")) ? 0 == g.length ? "c" : "d" : null) && (d.cm = g);
    d["new"] = String(!0 === jk(c, "inc"));
    d.ouri = a;
    (a = ek(c, "startupHints")) && e.j && Bg(d, e.j(a));
    c = ik(c, "resourceKey");
    null != c && (d.resourcekey = c);
    return Dn(f, d)
}
function Yw(a, c, d, e, f) {
    d = Xw(a, d);
    e = Nw(d, null, e, null);
    a = Lw(d, f, tm(c), d.g.o.B, a.g, c.R());
    return Dn(a, {
        ouri: e
    })
}
function Xw(a, c) {
    a = a.j.get(c);
    if (!a)
        throw Error("sc`" + c);
    return a
}
Vw.prototype.ob = function(a) {
    return this.o.ob(a)
}
;
function Zw(a, c) {
    this.g = void 0 === a ? !1 : a;
    this.yc = void 0 === c ? !1 : c
}
Zw.prototype.Ma = q("g");
function $w(a) {
    a = so(a);
    a.v || co(a, ax.v);
    a.j || (a.j = ax.j,
    eo(a, ax.C));
    return a.toString()
}
var ax = new bo(z.location.href);
function bx(a, c, d) {
    this.Bb = a;
    this.g = c;
    if (null === c && null !== d)
        throw Error("tc");
    this.j = d
}
bx.prototype.Ma = function() {
    return null !== this.g
}
;
function cx(a) {
    if (!a.g)
        throw Error("vc");
    return a.g
}
;function dx(a) {
    this.G = G(a)
}
y(dx, O);
dx.prototype.ca = function() {
    return of(this, 1)
}
;
function fx(a) {
    this.G = G(a)
}
y(fx, O);
var gx = dg(fx);
fx.ia = [1];
function hx(a) {
    this.g = a ? ef(a, dx, 1).reduce(function(c, d) {
        c[jf(d, 1)] = d;
        return c
    }, {}) : {}
}
function ix(a, c) {
    var d = !1;
    c = Cg(c);
    for (var e in a.g)
        c[e] || (delete a.g[e],
        d = !0);
    return d
}
;function jx(a) {
    this.G = G(a)
}
y(jx, O);
jx.prototype.getType = function() {
    return pf(this, 1)
}
;
jx.prototype.ca = function() {
    return of(this, 2)
}
;
function kx(a) {
    this.G = G(a)
}
y(kx, O);
kx.prototype.Qa = function() {
    return ef(this, jx, 3)
}
;
var lx = dg(kx);
kx.ia = [3];
function mx(a) {
    this.G = G(a)
}
y(mx, O);
var nx = dg(mx);
function ox(a) {
    this.G = G(a)
}
y(ox, O);
ox.prototype.ca = function() {
    return of(this, 2)
}
;
function px(a) {
    this.G = G(a)
}
y(px, O);
px.prototype.Qa = function() {
    return ef(this, ox, 1)
}
;
var qx = dg(px);
px.ia = [1];
function rx(a) {
    this.g = a
}
function sx(a, c, d) {
    a = a.g + "_" + c;
    return d ? a + "_" + d : a
}
function tx(a) {
    return a.g + "_static_resource_archive"
}
function ux(a) {
    var c = new Request("//resource_archive_metadata");
    return a.match(c).then(function(d) {
        return d ? d.text().then(function(e) {
            return e ? new hx(gx(e)) : null
        }) : null
    })
}
function vx(a, c) {
    var d = a.put
      , e = new Request("//resource_archive_metadata")
      , f = Response
      , g = new fx;
    ff(g, dx, 1, vg(c.g));
    return d.call(a, e, new f(g.Z()))
}
function wx(a) {
    a.set("docs-lfth", String(Date.now()))
}
function xx(a, c) {
    var d = {};
    var e = !a.headers || a.headers.entries().next().done;
    d.serviceworker_fetchUrl = a.url;
    d.serviceworker_isUrlMissing = String(!a.url);
    d.serviceworker_isBodyMissing = String(!a.body);
    d.serviceworker_headersMissing = String(e);
    e = !a.url || !a.body || e;
    a = c && null == yx(a, d);
    if (e || a)
        throw Gi(Error("wc"), d);
}
function yx(a, c) {
    c = void 0 === c ? {} : c;
    a = a.headers.get("cache-control");
    c.serviceworker_cacheControlHeader = a;
    c.serviceworker_isCacheControlHeaderMissing = String(!a);
    if (!a)
        return null;
    a = a.toLowerCase();
    if (-1 != a.indexOf("no-cache"))
        return 0;
    a = zx.exec(a);
    c.serviceworker_isMaxAgeMissing = String(!a);
    return a ? 1E3 * parseInt(a[1], 10) : null
}
function Ax(a, c) {
    return Promise.resolve().then(function() {
        return c.keys().then(function(d) {
            return d.filter(function(e) {
                return e.startsWith(a.g)
            })
        })
    })
}
function Bx(a, c) {
    var d = tx(a);
    return Ax(a, c).then(function(e) {
        return e.filter(function(f) {
            return f != d
        })
    })
}
function Cx(a, c, d) {
    d = void 0 === d ? !1 : d;
    return Dx(a).then(function(e) {
        return null === e ? new bx(c,null,null) : d ? Ex(e, a).then(function(f) {
            return new bx(c,e,f)
        }) : new bx(c,e,null)
    })
}
function Fx(a, c, d) {
    d = void 0 === d ? !1 : d;
    return Bx(a, c).then(function(e) {
        e = e.map(function(f) {
            return c.open(f).then(function(g) {
                return Cx(g, f, d)
            })
        });
        return Promise.all(e)
    })
}
function Ex(a, c) {
    a = a.Qa().filter(function(d) {
        return 1 == kf(d, 1)
    }).map(function(d) {
        d = d.ca();
        return Gx(c, d)
    });
    return Promise.all(a).then(function(d) {
        return d.filter(function(e) {
            return !!e
        })
    })
}
function Hx(a, c) {
    return Fx(a, c, !0).then(function(d) {
        d = d.filter(function(e) {
            return e.Ma()
        }).flatMap(function(e) {
            if (!e.j)
                throw Error("uc");
            return e.j.flatMap(function(f) {
                return f.Qa()
            })
        }).map(function(e) {
            return $w(e.ca())
        });
        return Cg(d)
    })
}
function Ix(a) {
    return a.match(new Request("//cache_metadata")).then(function(c) {
        return c ? c.text().then(function(d) {
            return d ? nx(d) : null
        }) : null
    })
}
function Dx(a) {
    return a.match(new Request("//manifest_cache_is_complete")).then(function(c) {
        return c ? c.text().then(function(d) {
            return d ? lx(d) : null
        }) : null
    })
}
function Gx(a, c) {
    c = $w(c);
    return a.match(new Request(c)).then(function(d) {
        return d ? Jx(d) : null
    })
}
function Jx(a) {
    a = new Map(a.headers.entries());
    return a.has("x-cachemanifest") ? qx(a.get("x-cachemanifest")) : null
}
var zx = /max-age=([0-9]+)/;
function Kx(a) {
    this.g = a
}
function Lx(a, c) {
    return c.open(tx(a.g)).then(function(d) {
        return d.keys()
    })
}
function Mx(a, c) {
    return a.map(function(d) {
        return $w(d)
    }).filter(function(d) {
        return !(d in c)
    })
}
function Nx(a) {
    return a.match(new Request("//manifest_cache_is_complete")).then(function(c) {
        return !!c
    })
}
function Ox(a, c, d, e, f) {
    return Px(a, c, d, e, f).then(function(g) {
        return g.g && g.yc
    })
}
function Px(a, c, d, e, f) {
    var g = e.Qa().filter(function(h) {
        return 1 === kf(h, 1)
    });
    return d.keys().then(function(h) {
        return Lx(a, c).then(function(k) {
            if (0 < h.length && 0 == k.length && f)
                return k = {},
                Qx(f, Error("xc"), (k.serviceworker_invalidCacheType = "chrome_corruption_recovery",
                k)),
                new Zw;
            var l = Cg(h.map(function(p) {
                return p.url
            }))
              , m = g.map(function(p) {
                return jf(p, 2)
            });
            l = Mx(m, l);
            if (0 != l.length && f)
                return k = {},
                Qx(f, Error("xc"), (k.serviceworker_invalidCacheType = "missing_action_resource",
                k.serviceworker_fetchUrl = l.sort().toString(),
                k)),
                new Zw;
            k = Rx(d, e, g, k, f);
            return nh(k).then(function(p) {
                var r = p.map(function(u) {
                    return u.value
                });
                p = r.every(function(u) {
                    return u.Ma()
                });
                r = r.every(function(u) {
                    return u.yc
                });
                return new Zw(p,r)
            })
        })
    })
}
function Rx(a, c, d, e, f) {
    var g = Cg(e.map(function(h) {
        return h.url
    }));
    return d.map(function(h) {
        h = h.ca();
        var k = $w(h);
        return a.match(new Request(k)).then(function(l) {
            if (null == l)
                return f && (l = {},
                Qx(f, Error("yc"), (l.serviceworker_invalidCacheType = "unexpected_internal_error",
                l))),
                new Zw;
            l = Jx(l);
            if (null == l)
                return f && (l = {},
                Qx(f, Error("zc"), (l.serviceworker_invalidCacheType = "unexpected_internal_error",
                l.serviceworker_fetchUrl = k,
                l))),
                new Zw;
            var m = l.Qa().map(function(p) {
                return jf(p, 2)
            });
            m = Mx(m, g);
            if (0 != m.length && f)
                return l = {},
                Qx(f, Error("xc"), (l.serviceworker_invalidCacheType = "missing_static_resource",
                l.serviceworker_fetchUrl = m.sort().toString(),
                l)),
                new Zw;
            m = !0;
            se(Re(l, 2)) != se(Re(c, 5)) && (m = !1);
            return new Zw(!0,m)
        })
    })
}
;function Sx(a, c) {
    this.g = a;
    this.j = c
}
;function Tx(a) {
    this.g = a
}
v = Tx.prototype;
v.match = function(a, c) {
    return Ux("CacheStorage.match", this.g.match(a, c))
}
;
v.has = function(a) {
    return Ux("CacheStorage.has", this.g.has(a))
}
;
v.open = function(a) {
    return Ux("CacheStorage.open", this.g.open(a)).then(function(c) {
        return new Vx(c)
    })
}
;
v.delete = function(a) {
    return Ux("CacheStorage.delete", this.g.delete(a))
}
;
v.keys = function() {
    return Ux("CacheStorage.keys", this.g.keys())
}
;
function Vx(a) {
    this.g = a
}
v = Vx.prototype;
v.match = function(a, c) {
    return Ux("Cache.match", this.g.match(a, c))
}
;
v.matchAll = function(a, c) {
    return Ux("Cache.matchAll", this.g.matchAll(a, c))
}
;
v.add = function(a) {
    return Ux("Cache.add", this.g.add(a))
}
;
v.addAll = function(a) {
    return Ux("Cache.addAll", this.g.addAll(a))
}
;
v.put = function(a, c) {
    return Ux("Cache.put", this.g.put(a, c))
}
;
v.delete = function(a, c) {
    return Ux("Cache.delete", this.g.delete(a, c))
}
;
v.keys = function(a, c) {
    return Ux("Cache.keys", this.g.keys(a, c))
}
;
function Ux(a, c) {
    return c.catch(function(d) {
        var e = {};
        throw Gi(d, (e.serviceworker_failedCacheOp = a,
        e));
    })
}
;function Wx(a) {
    this.j = a;
    this.g = this.o = 0
}
v = Wx.prototype;
v.match = function(a, c) {
    var d = this;
    this.o++;
    return this.j.match(a, c).finally(function() {
        d.o--
    })
}
;
v.matchAll = function(a, c) {
    var d = this;
    this.o++;
    return this.j.matchAll(a, c).finally(function() {
        d.o--
    })
}
;
v.add = function(a) {
    var c = this;
    this.g++;
    return this.j.add(a).finally(function() {
        c.g--
    })
}
;
v.addAll = function(a) {
    var c = this;
    this.g++;
    return this.j.addAll(a).finally(function() {
        c.g--
    })
}
;
v.put = function(a, c) {
    var d = this;
    this.g++;
    return this.j.put(a, c).finally(function() {
        d.g--
    })
}
;
v.delete = function(a, c) {
    var d = this;
    this.g++;
    return this.j.delete(a, c).finally(function() {
        d.g--
    })
}
;
v.keys = function(a, c) {
    var d = this;
    this.o++;
    return this.j.keys(a, c).finally(function() {
        d.o--
    })
}
;
function Xx(a, c, d) {
    this.g = a;
    this.A = c;
    this.o = d;
    this.v = Promise.resolve(null);
    this.j = null
}
function Yx(a) {
    return Zx(a).then(n()).catch(function(c) {
        var d = a.A;
        c = Ei(c);
        uq(d.g, c)
    })
}
v = Xx.prototype;
v.match = function(a, c) {
    return this.g.match(a, c)
}
;
v.has = function(a) {
    return this.g.has(a)
}
;
v.open = function(a) {
    var c = this;
    return a == this.o ? this.v.then(function(d) {
        return null != d ? d : Zx(c)
    }) : this.g.open(a)
}
;
function Zx(a) {
    var c = a.g.open(a.o).then(function(d) {
        a.j = new Wx(d);
        return a.j
    });
    a.v = c.catch(aa(null));
    return c
}
v.delete = function(a) {
    a == this.o && (this.v = Promise.resolve(null),
    this.j = null);
    return this.g.delete(a)
}
;
v.keys = function() {
    return this.g.keys()
}
;
function $x(a) {
    a = new bo(a);
    var c = a.o.split("/").pop();
    return a.j.endsWith(".google.com") && a.o.includes("/ac/") && c.startsWith("logo.")
}
function ay(a) {
    var c = new bo(a);
    (c = (c.j.startsWith("photos-image-dev.") && c.j.endsWith(".google.com") || c.j.endsWith(".googleusercontent.com") || c.j.endsWith(".ggpht.com")) && c.o.includes("/ogw/")) || (a = new bo(a),
    c = !a.j.startsWith("photos-image-dev.") && a.j.endsWith(".google.com") && a.o.includes("/ogw/"));
    return c
}
;function by(a, c) {
    a = cy(a);
    return z.fetch(a, c).then(function(d) {
        var e = d.headers.get("content-type");
        return e && e.includes("text/plain") ? d.text().then(function(f) {
            return z.fetch(f, c)
        }) : d
    })
}
function cy(a) {
    a = new URL(a);
    var c = a.searchParams;
    c.set("alr", "yes");
    a.search = c.toString();
    return a.toString()
}
;function dy(a, c, d, e) {
    return ey(a, 3, 0, void 0 === c ? null : c, void 0 === d ? null : d, void 0 === e ? !1 : e, !1)
}
function ey(a, c, d, e, f, g, h) {
    var k = {};
    g && (k.redirect = "error");
    h && (k.cache = "reload");
    fy(a.url) && (k.credentials = "include");
    return (ay(a.url) ? by(a.url, k) : z.fetch(a.clone(), k)).then(function(l) {
        if (200 !== l.status) {
            var m = {
                serviceworker_fetchErrorReason: "failure_response_status"
            };
            m.serviceworker_responseStatus = String(l.status);
            throw Gi(new Jv(l.status,"Invalid response status."), m);
        }
        return l
    }).catch(function(l) {
        d += 1;
        if (d >= c) {
            var m = {};
            m.serviceworker_fetchUrl = a.url;
            l instanceof TypeError && (m.serviceworker_fetchErrorReason = "type_error");
            z.navigator && null != z.navigator.onLine && (m.serviceworker_navigatorIsOnline = String(z.navigator.onLine));
            throw Gi(l, m);
        }
        f && 1 === d && f();
        return ey(a, c, d, e, f, g, !0)
    })
}
var gy = [$x, ay];
function fy(a) {
    return gy.some(function(c) {
        return c(a)
    })
}
var hy = /\.gstatic\.|\/doclist\/|\/static\/|googleusercontent\.com\/|google\.com\/images\/errors\/|apis\.google\.com/
  , iy = ["/cleardot.gif", "/netcheck.gif", "//csi.gstatic.com/csi"];
function jy(a) {
    return ay(a) || $x(a) ? !0 : hy.test(a) && iy.every(function(c) {
        return !a.includes(c)
    })
}
function ky(a) {
    if (a.T)
        return a.T && a.T.ya.includes("offline/iframeapi") ? !1 : !0;
    a = a.U.B;
    return !!a && ly.includes(a)
}
var ly = [1, 2, 3];
var my = {
    "undefined-cold-start-reason": 0,
    offline: 1,
    "server-error": 2,
    "flaky-connection-pre-response": 3,
    "direct-cold-start": 6,
    "server-document-not-found": 7,
    "server-document-deleted": 8,
    "server-suggested": 9
};
function ny(a) {
    switch (a) {
    case "cache-needs-update":
        return "The cache needs to be updated.";
    case "document-model-needs-resync":
        return "The document model needs to be resynced.";
    case "document-not-available-locally":
        return "The document was not available locally.";
    case "undefined-cold-start-reason":
        return "Cold start occurred for an undefined reason.";
    case "offline":
        return "Server was unreachable or network was unavailable.";
    case "server-error":
        return "Server responded with an error.";
    case "flaky-connection-pre-response":
        return "Client detected a slow network or slow server.";
    case "direct-cold-start":
        return "Client generated cold-start url directly.";
    case "server-document-not-found":
        return "The document exists locally but does not exist on server yet.";
    case "server-document-deleted":
        return "The docuement was deleted from the server.";
    case "server-suggested":
        return "The server suggested that cold-start is preferred here.";
    case "missing-action-info":
        return "The request did not contain the requisite action information.";
    case "cannot-determine-editor":
        return "Unable to determine the editor to redirect to based on url.";
    default:
        return "Fetcher did not provide a Response object."
    }
}
;function oy(a, c) {
    a.j.push(c)
}
function py(a, c, d, e) {
    e = void 0 === e ? {} : e;
    e.serviceworker_isNullResponse = "false";
    qy(a, c, e, d);
    ry(a, d, e)
}
function sy(a, c, d) {
    d = void 0 === d ? {} : d;
    vq(a.g, function() {
        var e = d;
        e = void 0 === e ? {} : e;
        e.serviceworker_codePath = "install";
        uq(a.g, c, e)
    }, a)()
}
function ty(a, c, d, e) {
    e = void 0 === e ? {} : e;
    e.serviceworker_cacheUpdateError = "true";
    e.serviceworker_codePath = d;
    ry(a, c, e)
}
function Qx(a, c, d) {
    d = void 0 === d ? {} : d;
    ty(a, c, "internalCacheUpdate", d)
}
function uy(a, c) {
    var d = void 0 === d ? {} : d;
    d.serviceworker_codePath = "activate";
    ry(a, c, d)
}
function vy(a, c, d, e) {
    e = void 0 === e ? {} : e;
    e.serviceworker_codePath = "messageHandler";
    d && (e.serviceworker_messageHandler_requestType = kf(d, 1));
    ry(a, c, e)
}
function wy(a, c, d, e) {
    e = void 0 === e ? null : e;
    var f = void 0 === f ? {} : f;
    var g = d.Wa
      , h = ky(c);
    qy(a, c, f, g);
    c = !d.ta;
    f.serviceworker_isNullResponse = String(c);
    f.fetch_handling_recovery = c ? e && "error" != e.type ? "error_page" : "none" : "fallback";
    c && h ? sq(a.g, g || Error(ny(d.j)), f) : g && (h ? sq(a.g, g, f) : uq(a.g, g, f))
}
function xy(a) {
    je(a, "__INTERNAL_errorShouldBeSampled", "true")
}
function yy(a) {
    return a instanceof TypeError && "Failed to fetch" == a.message
}
function qy(a, c, d, e) {
    d.serviceworker_navigatorIsOnline = String(z.navigator.onLine);
    (void 0 === e ? null : e)instanceof TypeError && (d.serviceworker_fetchErrorReason = "type_error");
    e = c.T ? c.T.j ? "coldStartUrl" : c.T.kc ? "homescreenAction" : c.T.Ob ? "editorCreateAction" : c.T.o ? "offlineCommonAction" : "editorAction" : c.j ? "staticContent" : null;
    null != e && (d.serviceworker_requestType = e);
    c.T && null != c.T.g && (d.sw_docType = c.T.g);
    d.serviceworker_resourceCategory = String(c.U.B);
    e = c.ga;
    var f = ki(ji(e.url)[5] || null);
    f = f.substring(f.lastIndexOf("/"));
    -1 < zy.indexOf(f) && (d.serviceworker_actionPath = f);
    d.serviceworker_fetchError_fullUrl = Lv(e.url);
    d.serviceworker_codePath = "fetch";
    d.serviceworker_requestMode = e.mode;
    d.serviceworker_requestDestination = e.destination;
    d.serviceworker_requestRedirectMode = e.redirect;
    d.serviceworker_clientId = c.clientId || "";
    (f = wi(e.url, "usp")) && (d.serviceworker_fetchUsp = f);
    e = so(e.referrer);
    e = io(e, "");
    e = go(e, "");
    d.serviceworker_referrer = e.toString();
    for (e = 0; e < a.j.length; e++) {
        f = (0,
        a.j[e])(c);
        for (var g in f)
            d[g] = f[g]
    }
}
function ry(a, c, d) {
    if ("true" === ke(c).__INTERNAL_errorShouldBeSampled) {
        a = a.g;
        d = void 0 === d ? {} : d;
        var e = void 0 === e ? !1 : e;
        var f = void 0 === f ? 0 : f;
        2 > Math.floor(100 * Math.random()) && (d.sampling_samplePercentage = "2",
        d.sampling_sampledBy = "random",
        0 == f ? a.info(c, d, e) : 1 == f ? uq(a, c, d, e) : 2 == f && sq(a, c, d, e))
    } else
        a.g.info(c, d)
}
var zy = "/comment /create /edit /hs /view /preview /viewcomments /open".split(" ");
function Ay(a, c, d, e, f) {
    this.A = c;
    this.B = new Kx(c);
    this.v = a;
    this.o = d;
    this.j = e;
    this.C = of(d, 1);
    this.g = f
}
Ay.prototype.update = function() {
    var a = this;
    return this.v.open(sx(this.A, this.C, jf(this.o, 2))).then(function(c) {
        return Nx(c).then(function(d) {
            return d ? Ox(a.B, a.v, c, a.o, a.j) : !1
        }).then(function(d) {
            if (!d)
                return By(a, c)
        })
    })
}
;
function By(a, c) {
    return Cy(a, c).then(function() {
        var d = a.o;
        return c.put(new Request("//manifest_cache_is_complete"), new Response(d.Z()))
    }).catch(function(d) {
        return a.v.delete(sx(a.A, a.C, jf(a.o, 2))).then(function() {
            throw Gi(d, {
                failedCacheName: a.C
            });
        })
    })
}
function Cy(a, c) {
    return a.v.open(tx(a.A)).then(function(d) {
        return ux(d).then(function(e) {
            e = e || new hx;
            var f = a.o.Qa().filter(function(g) {
                return 1 === kf(g, 1)
            });
            Dy(a.g, f.length);
            return Ey(a, f, c, d, e)
        })
    }).catch(function(d) {
        d instanceof Jv && 412 == d.j && xy(d);
        throw d;
    })
}
function Ey(a, c, d, e, f) {
    c = c.map(function(g) {
        return function() {
            return Fy(a, d, g)
        }
    });
    return Zn(new Yn(c)).then(function(g) {
        g = g.filter(function(h) {
            return !!h
        }).flatMap(function(h) {
            return h.Qa()
        });
        Xc(g, void 0, function(h) {
            return h.ca()
        });
        return Gy(a, e, g, f, e)
    })
}
function Gy(a, c, d, e, f) {
    Hy(a.g, d.length);
    d = d.map(function(g) {
        return function() {
            return Iy(a, c, g, e)
        }
    });
    return Zn(new Yn(d)).finally(function() {
        return vx(f, e).catch(n())
    })
}
function Iy(a, c, d, e) {
    var f = d.ca()
      , g = Date.now()
      , h = !1
      , k = {
        headers: {}
    };
    return Jy(a, c, d).then(function(l) {
        if (l)
            h = !0;
        else
            return Ky(a, f, k, function() {
                a.g.g++
            }).then(function(m) {
                try {
                    xx(m, !0)
                } catch (r) {
                    var p = {};
                    Qx(a.j, Ei(r), (p.serviceworker_manifestUrl = f,
                    p.serviceworker_isResourceFromServer = "true",
                    p))
                }
                p = new Request(f);
                wx(p.headers);
                return c.put(p, m)
            })
    }).then(function() {
        var l = $w(f)
          , m = e.g[l];
        m || (m = new dx,
        M(m, 1, l),
        e.g[l] = m);
        K(m, 2, g);
        Ly(a.g, !0, !0, h)
    }).catch(function(l) {
        Ly(a.g, !0, !1, h);
        throw l;
    })
}
function Fy(a, c, d) {
    var e = d.ca();
    return Ky(a, e, {
        headers: {
            "x-include-cachemanifest": "true"
        },
        credentials: "include"
    }, function() {
        a.g.g++
    }).then(function(f) {
        var g = null;
        try {
            g = Jx(f),
            xx(f, !0)
        } catch (k) {
            var h = {};
            Qx(a.j, Ei(k), (h.serviceworker_manifestUrl = e,
            h.serviceworker_isResourceFromServer = "true",
            h))
        }
        null == g && (h = {},
        Qx(a.j, Error("Ac"), (h.serviceworker_fetchUrl = e,
        h)));
        h = new Request(e);
        wx(h.headers);
        return c.put(h, f).then(function() {
            Ly(a.g, !1, !0, !1);
            return g
        })
    }).catch(function(f) {
        Ly(a.g, !1, !1, !1);
        throw f;
    })
}
function Jy(a, c, d) {
    var e = d.ca();
    return My(a, c, e).then(function(f) {
        if (!f)
            return null;
        var g = f.request;
        f = f.g;
        try {
            xx(f, !0)
        } catch (l) {
            return xy(l),
            g = {},
            Qx(a.j, l, (g.serviceworker_manifestUrl = e,
            g.serviceworker_isResourceFromServer = "false",
            g)),
            null
        }
        var h = g.headers.get("docs-lfth");
        h = parseInt(h, 10);
        h = isNaN(h) ? null : h;
        var k = yx(f) || 0;
        return null === h || Date.now() > h + k ? null : new Ny(g,f)
    })
}
function My(a, c, d) {
    return c.keys(d).then(function(e) {
        return 0 == e.length ? null : c.match(d).then(function(f) {
            var g = (new Request(d)).url
              , h = e.some(function(p) {
                return p.url != g
            })
              , k = !!f && go(so(g), null).toString() != go(so(f.url), null).toString()
              , l = !!f && ay(g) && ay(f.url);
            if (1 < e.length || !f || (h || k) && !l) {
                l = Error("Bc");
                xy(l);
                var m = {};
                k = (m.serviceworker_manifestUrl = d,
                m.sw_expectedUrl = g,
                m.sw_cacheKeysLength = String(e.length),
                m.sw_hasMismatchingUrls = String(h),
                m.sw_hasMismatchingResponseUrl = String(k),
                m.sw_responseMissing = String(!f),
                m);
                h && (k.sw_allMatchedUrls = e.map(function(p) {
                    return p.url
                }).join());
                Qx(a.j, l, k)
            }
            return (h = 1 == e.length ? e[0] : e.find(function(p) {
                return p.url == g
            })) && f ? new Ny(h,f) : null
        })
    })
}
function Ky(a, c, d, e) {
    c = new Request(c,d);
    return dy(c, a.g, e, !0).catch(function(f) {
        f = Ei(f);
        yy(f) && xy(f);
        throw f;
    })
}
function Ny(a, c) {
    this.request = a;
    this.g = c
}
;function Oy(a, c) {
    this.v = a;
    this.O = c;
    this.A = null;
    this.J = this.I = this.M = !1;
    this.g = this.C = this.B = this.H = this.L = this.F = this.j = this.o = this.D = 0
}
function Py(a, c) {
    var d = Date.now() - a.A
      , e = new Sr;
    a: switch (a.O) {
    case "new_install":
        var f = 1;
        break a;
    case "reinstall":
        f = 2;
        break a;
    case "cache_only_update":
        f = 3;
        break a;
    default:
        throw Error("Cc");
    }
    e = N(e, 1, f);
    c = J(e, 2, c);
    c = J(c, 3, a.J);
    d = K(c, 4, 1E3 * d);
    d = qf(d, 5, a.D);
    d = qf(d, 6, a.o);
    d = qf(d, 7, a.j);
    d = qf(d, 8, a.F);
    d = qf(d, 9, a.L);
    d = qf(d, 10, a.H);
    d = qf(d, 11, a.B);
    d = qf(d, 12, a.C);
    d = J(d, 13, a.M);
    d = J(d, 14, a.I);
    d = qf(d, 16, a.g);
    e = qf(d, 17, 0);
    d = a.v.Za(100007, 0);
    c = Qy(d);
    f = new bs;
    e = I(f, Sr, 6, e);
    I(c, bs, 50, e);
    a.v.la(d)
}
function Dy(a, c) {
    a.D++;
    a.j += c
}
function Hy(a, c) {
    a.o += c
}
function Ly(a, c, d, e) {
    c ? (a.F++,
    d || a.L++,
    e && a.H++) : (a.B++,
    d || a.C++)
}
;function Ry(a, c, d) {
    this.j = a;
    this.g = c;
    this.o = d
}
function Sy(a, c, d) {
    d = void 0 === d ? null : d;
    if (null != d && 0 == d.length)
        throw Error("Dc");
    return Fx(a.g, a.j).then(function(e) {
        if (0 != e.length) {
            var f = e.filter(function(k) {
                return k.Ma()
            })
              , g = f.map(function(k) {
                var l = a.g;
                k = cx(k);
                return sx(l, of(k, 1), null)
            });
            Xc(g);
            if (d) {
                var h = {};
                g.forEach(function(k) {
                    var l = d.find(function(m) {
                        return sx(a.g, of(m, 1), null) == k
                    });
                    h[k] = l || null
                })
            } else
                h = null;
            g = g.map(function(k) {
                var l = f.filter(function(m) {
                    return m.Bb.startsWith(k)
                });
                return Ty(a, k, l, h)
            });
            return Promise.all(g).then(function(k) {
                var l = k.filter(function(u) {
                    return null != u
                }).map(function(u) {
                    return u.Bb
                });
                k = e.map(function(u) {
                    return u.Bb
                }).filter(function(u) {
                    return !l.includes(u)
                });
                if (k.length == e.length) {
                    var m = 0 == f.length ? "Cleaning up all manifest caches (all incomplete)" : "Cleaning up all manifest caches"
                      , p = {};
                    p = (p.serviceworker_cacheCleanupErrorReason = null == d ? "pre_update_manifest_cleanup" : "post_update_manifest_cleanup",
                    p.serviceworker_cacheUpdateReason = c,
                    p);
                    Qx(a.o, Error(m), p)
                }
                var r = k.map(function(u) {
                    return a.j.delete(u)
                });
                return nh(r).then(function() {
                    return Promise.all(r)
                })
            })
        }
    })
}
function Ty(a, c, d, e) {
    if (!e)
        return Promise.resolve(Uy(d));
    var f = e[c];
    return f ? Vy(a, f).then(function(g) {
        return g ? Wy(a, d, f) : Uy(d)
    }) : Promise.resolve(null)
}
function Vy(a, c) {
    var d = sx(a.g, of(c, 1), jf(c, 2));
    return a.j.has(d).then(function(e) {
        return e ? a.j.open(d).then(function(f) {
            return Nx(f)
        }) : !1
    })
}
function Uy(a) {
    if (0 == a.length)
        return null;
    if (1 == a.length)
        return a[0];
    a = Vc(a);
    a.sort(function(c, d) {
        return Xy(d) - Xy(c)
    });
    return a[0]
}
function Xy(a) {
    if (!a.Ma())
        return -1;
    a = cx(a);
    a = se(Re(a, 6));
    return null == a ? -1 : a
}
function Wy(a, c, d) {
    var e = sx(a.g, of(d, 1), jf(d, 2));
    return c.find(function(f) {
        return f.Bb == e
    }) || null
}
;function Yy() {
    Q.call(this);
    this.g = {};
    this.j = new Jq;
    R(this, this.j)
}
y(Yy, Q);
function Zy(a, c, d) {
    a.g[c] = new $y(d);
    a.j.Ga(function() {
        var e = a.g[c];
        e && az(e) && delete a.g[c]
    }, 3E4)
}
function bz(a, c, d) {
    a = a.g[c];
    return null == a || az(a, void 0 === d ? 0 : d) ? Promise.resolve(null) : a.g
}
Yy.prototype.K = function() {
    Q.prototype.K.call(this);
    this.g = {}
}
;
function $y(a) {
    var c = Date.now() + 3E4;
    this.g = a;
    this.j = c
}
function az(a, c) {
    return Date.now() >= a.j - (void 0 === c ? 0 : c)
}
;function cz(a, c, d, e, f, g, h, k) {
    Q.call(this);
    this.j = new rx(d);
    this.A = k;
    d = S(this.A, "docs-sw-ecfr");
    this.g = new Xx(d ? new Tx(a.caches) : a.caches,g,tx(this.j));
    this.M = c;
    this.J = f;
    this.o = g;
    this.F = a;
    this.D = h;
    this.I = new Ry(this.g,this.j,this.o);
    this.B = new Yy;
    R(this, this.B);
    this.v = null;
    this.H = !1
}
y(cz, Q);
cz.prototype.start = function() {
    Yx(this.g)
}
;
function dz(a) {
    Gj(a.A).forEach(function(c) {
        var d = $w(c);
        bz(a.B, d, 5E3).then(function(e) {
            e || Zy(a.B, d, ez(a, d))
        })
    })
}
function fz(a, c) {
    var d = new Oy(a.D,c);
    d.A = Date.now();
    var e = gz(a).then(function(g) {
        if (g)
            return a.M.get(c).then(function(h) {
                return Yx(a.g).then(function() {
                    return Sy(a.I, c)
                }).catch(function(k) {
                    var l = {};
                    throw Gi(k, (l.serviceworker_cacheCleanupErrorReason = "pre_update_manifest_cleanup",
                    l));
                }).then(function() {
                    return hz(a, c, h, d)
                }).catch(function(k) {
                    if (k instanceof Error && iz(a, k)) {
                        var l = {};
                        Qx(a.o, k, (l.serviceworker_invalidCacheType = "unexpected_internal_error",
                        l));
                        return jz(a).then(function() {
                            return hz(a, c, h, d)
                        })
                    }
                    throw k;
                })
            });
        d.M = !0
    })
      , f = lp(27E4).then(function() {
        d.J = !0;
        var g = Error("Ec");
        xy(g);
        throw g;
    });
    return Promise.race([e, f]).then(function() {
        a.v = null
    }).catch(function(g) {
        a.v = Ei(g)
    }).then(function() {
        a.H = !0;
        Py(d, !a.v);
        return Promise.resolve(a.D.bb()).catch(function(g) {
            Qx(a.o, Ei(g))
        }).then(function() {
            if (a.v)
                throw a.v;
        })
    })
}
function hz(a, c, d, e) {
    e.I = !0;
    for (var f = [], g = 0; g < d.length; g++)
        f.push((new Ay(a.g,a.j,d[g],a.o,e)).update());
    return Promise.resolve(nh(f)).then(function() {
        if (d.length)
            return Sy(a.I, c, d)
    }).catch(function(h) {
        var k = {};
        Qx(a.o, Ei(h), (k.serviceworker_cacheCleanupErrorReason = "post_update_manifest_cleanup",
        k))
    }).then(function() {
        return kz(a)
    }).catch(function(h) {
        var k = {};
        Qx(a.o, Ei(h), (k.serviceworker_cacheCleanupErrorReason = "archive_cleanup",
        k))
    }).then(function() {
        return Promise.all(f)
    })
}
function iz(a, c) {
    return S(a.A, "docs-sw-efcr") ? c.message.includes("Unexpected internal error.") : "Unexpected internal error." == c.message
}
function gz(a) {
    return Promise.resolve().then(function() {
        return Vu(a.J)
    }).then(function(c) {
        return (new Promise(function(d, e) {
            lu(c.rb(), d, e)
        }
        )).then(function(d) {
            return 1 == d.length && d[0].R() == T(a.A, "docs-offline-lsuid")
        })
    })
}
function jz(a) {
    return Ax(a.j, a.g).then(function(c) {
        c = c.map(function(d) {
            return a.g.delete(d)
        });
        return lz(c)
    })
}
function mz(a, c, d) {
    return Gj(a.A).length ? bz(a.B, c).then(function(e) {
        return e ? (d.V = !0,
        e.clone()) : ez(a, c)
    }) : ez(a, c)
}
function ez(a, c) {
    return a.g.open(tx(a.j)).then(function(d) {
        return d.match(c)
    }).then(function(d) {
        return d || null
    })
}
function nz(a, c) {
    return Ax(a.j, a.g).then(function(d) {
        d = d.map(function(e) {
            return a.g.open(e).then(function(f) {
                return oz(f, c)
            })
        });
        return pz(d)
    })
}
function kz(a) {
    return Hx(a.j, a.g).then(function(c) {
        return a.g.open(tx(a.j)).then(function(d) {
            return ux(d).then(function(e) {
                var f = e || new hx;
                return d.keys().then(function(g) {
                    return qz(d, g, f).then(function() {
                        return rz(a, d, g, f, c)
                    })
                }).then(function() {
                    return vx(d, f)
                })
            })
        })
    })
}
function qz(a, c, d) {
    c = c.map(function(e) {
        return e.url
    });
    return ix(d, c) ? vx(a, d) : Promise.resolve()
}
function rz(a, c, d, e, f) {
    return a.F.clients.matchAll({
        includeUncontrolled: !0
    }).then(function(g) {
        g = 0 == g.filter(function(h) {
            return h.url.startsWith(a.F.registration.scope)
        }).length;
        return sz(c, d, e, f, g)
    })
}
function sz(a, c, d, e, f) {
    return lz(c.map(function(g) {
        var h = d.g[g.url] || null;
        h = h && gf(h, 2);
        if ((null == h || h + 18144E5 < Date.now() || f) && !e[g.url])
            return delete d.g[g.url],
            a.delete(g)
    })).then(n())
}
function pz(a) {
    return new Promise(function(c, d) {
        var e = !1;
        Promise.all(a.map(function(f) {
            return f.then(function(g) {
                g && !e && (e = !0,
                c(g))
            })
        })).then(function() {
            e || c(null)
        }).catch(function(f) {
            d(f)
        })
    }
    )
}
function lz(a) {
    return Promise.resolve(nh(a)).then(function() {
        return Promise.all(a)
    })
}
function oz(a, c) {
    return Promise.all([Nx(a), Ix(a), a.match(c, void 0)]).then(function(d) {
        var e = d[1]
          , f = d[2];
        return d[0] && f ? new Sx(f,e || new mx) : null
    })
}
;function tz() {
    var a = uz
      , c = vz
      , d = wz;
    var e = void 0 === e ? yo() : e;
    this.j = a;
    this.g = c;
    this.v = d;
    this.o = e
}
function xz(a) {
    return ps(a.j).then(function(c) {
        return yz(a, c)
    })
}
function yz(a, c) {
    return c ? zz(a, c.g).then(function(d) {
        return d.map(function(e) {
            var f = new ko
              , g = c.j
              , h = ik(g, "locale") || "en";
            f.add("ouid", g.R());
            f.add("hl", h);
            f.add("forcehl", 1);
            f.add("jobset", e);
            a.o && f.add("Debug", !0);
            e = bo;
            g = ji(z.location.href);
            return go(fo(new e(hi(g[1], g[2], g[3], g[4])), a.v + "/offline/cachemanifest"), f)
        })
    }) : ih([])
}
function zz(a, c) {
    var d = (new dh(function(f, g) {
        xn(c.j.Xa(), a.g, f, g)
    }
    )).then(function(f) {
        return f.sa()
    })
      , e = (new dh(function(f, g) {
        ut(c.j.C, null, f, g)
    }
    )).then(function(f) {
        f = f.filter(function(g) {
            return g.getType() == a.g
        }).map(function(g) {
            return g.sa()
        });
        return wg(Cg(f))
    });
    return mh([d, e]).then(function(f) {
        var g = f[0];
        f = f[1];
        return 0 <= f.indexOf(g) ? f : f.concat(g)
    })
}
;function Az() {
    this.g = new tz
}
Az.prototype.get = function(a) {
    return xz(this.g).then(function(c) {
        c = c.map(function(d) {
            d.g.set("reason", a);
            d = new Request(d.toString(),{
                credentials: "include"
            });
            return dy(d).then(function(e) {
                return e.text()
            }).then(function(e) {
                if (!e)
                    throw Error("Gc");
                if (!lc(e, ")]}'\n"))
                    throw Error("Hc");
                return lx(e.substr(5))
            }).catch(function(e) {
                e = Ei(e);
                yy(e) && xy(e);
                throw e;
            })
        });
        return mh(c)
    })
}
;
function Bz(a, c, d, e, f) {
    if (null == a && !d)
        throw Error("Ic");
    this.ta = a;
    this.o = c;
    this.Ha = d;
    this.j = e || null;
    this.g = f || null;
    this.Wa = null
}
function Cz(a) {
    return a.ta.headers.get("Location")
}
function Dz(a, c) {
    a.ta.headers.set("Location", c)
}
function Ez(a, c) {
    a.Wa = a.Wa ? Gi(c, {
        serviceworker_multipleFetchErrors: "true"
    }) : c
}
function Fz(a, c) {
    a = new Bz(null,a,!0);
    Ez(a, c);
    return a
}
function Gz(a) {
    return new Bz(null,a,!0,"document-not-available-locally")
}
function Hz(a, c) {
    return new Bz(a,"network",!0,c)
}
function Iz(a, c, d) {
    return new Bz(Jz(a),"cache-storage",!0,d,c)
}
function Jz(a) {
    var c = ji(a);
    a = hi(c[1], null, c[3], c[4]) ? a : z.location.origin + (a.startsWith("/") ? a : "/" + a);
    c = new Headers;
    c.set("Location", a);
    return new Response("",{
        status: 302,
        headers: c
    })
}
function Kz(a, c) {
    c = my[c];
    var d = Cz(a)
      , e = Bn(d);
    e.csr = "" + c;
    c = Dn(d, e);
    Dz(a, c)
}
function Lz(a, c) {
    var d = Cz(a)
      , e = Bn(d);
    e.fcfr = "" + c;
    c = Dn(d, e);
    Dz(a, c)
}
;function Mz(a) {
    this.g = a
}
Mz.prototype.fetch = function(a) {
    var c = this;
    return Nz(a).then(function(d) {
        return Oz(c, a, d)
    })
}
;
function Nz(a) {
    var c = a.ga.url;
    if (a.T && a.T.j) {
        a = so(a.ga.url);
        c = a.g;
        var d = c.get("uc");
        !xo(c, "hl") && d && (d = Pz.exec(d)) && (c.add("hl", d[1]),
        c.add("forcehl", "1"));
        a = Qz(a.toString(), Rz)
    } else
        a = a.T && a.T.o ? Qz(a.ga.url, Sz) : Promise.resolve(c);
    return a
}
function Oz(a, c, d) {
    var e = a.g.g.j;
    c.U.M = null == e ? 0 : e.o;
    c.U.O = null == e ? 0 : e.g;
    c.U.o = Date.now();
    return Tz(a, d, c).then(function(f) {
        var g = c.U;
        g.A || (g.j = Date.now() - g.o,
        g.A = !1);
        c.U.L = !!f;
        if (!f)
            return (f = ky(c) ? new Kv(c.ga.url) : void 0) ? (je(f, "serviceworker_expectedCachedUrl", Lv(d)),
            Fz("cache-storage", f)) : new Bz(null,"cache-storage",!0);
        try {
            xx(f, !1)
        } catch (h) {
            return f = new Bz(f,"cache-storage",!0),
            g = {},
            Ez(f, Gi(h, (g.serviceworker_isResourceFromServer = "false",
            g))),
            f
        }
        return new Bz(f,"cache-storage",!1)
    })
}
function Tz(a, c, d) {
    return d.j ? mz(a.g, c, d.U) : nz(a.g, c).then(function(e) {
        return e ? e.g : null
    })
}
function Qz(a, c) {
    a = so(a);
    for (var d = a.g, e = new ko, f = 0; f < c.length; f++) {
        var g = c[f];
        xo(d, g) && e.add(g, d.get(g, ""))
    }
    go(a, e);
    return Promise.resolve(a.toString())
}
var Pz = RegExp("([a-zA-Z-_]+)(,i){0,1}")
  , Rz = "ouid forcehl hl jobset Debug ftrack".split(" ")
  , Sz = ["ouid", "Debug"];
function Uz(a) {
    this.g = a
}
Uz.prototype.R = q("g");
function Vz(a) {
    this.G = G(a)
}
y(Vz, O);
function Wz(a) {
    this.G = G(a)
}
y(Wz, O);
function Xz(a) {
    this.G = G(a)
}
y(Xz, O);
function Yz() {
    this.j = this.g = null
}
function Zz(a, c, d) {
    a.g = c;
    a.j = d;
    return a
}
function Qy(a) {
    var c = H(a.g, ds, 5);
    null == c && (c = new ds,
    I(a.g, ds, 5, c));
    return c
}
function $z(a) {
    gf(a.g, 10);
    null != gf(a.g, 6) || gf(a.g, 10);
    if (2 == kf(H(a.g, Xz, 8), 3) && null != gf(a.g, 13)) {
        var c = H(H(a.g, Xz, 8), Vz, 2);
        gf(c, 2)
    }
    var d = H(a.g, ds, 5);
    null != d && (c = a.g,
    d = sf(d),
    I(c, ds, 5, d));
    return a.g
}
;function aA() {
    this.g = {};
    this.o = {};
    this.j = null
}
;function bA(a) {
    this.G = G(a)
}
y(bA, O);
function cA(a) {
    this.G = G(a)
}
y(cA, O);
cA.prototype.sa = function() {
    return pf(this, 9)
}
;
function dA(a) {
    this.G = G(a)
}
y(dA, O);
function eA(a) {
    this.G = G(a)
}
y(eA, O);
function fA(a) {
    this.G = G(a)
}
y(fA, O);
function gA(a) {
    this.G = G(a)
}
y(gA, O);
function hA(a) {
    this.G = G(a)
}
y(hA, O);
function iA(a) {
    this.G = G(a)
}
y(iA, O);
iA.prototype.sa = function() {
    return pf(this, 4)
}
;
function jA() {
    this.g = new eA;
    this.o = null;
    this.A = new dA;
    N(this.A, 1, 6);
    this.j = this.v = null
}
function kA(a) {
    null == a.o && (a.o = new iA);
    return a.o
}
function lA(a) {
    null == a.j && (a.j = new cA);
    return a.j
}
function mA(a) {
    null != jf(a.g, 1) && null != kf(a.g, 6) && kf(a.g, 6)
}
;function hs(a) {
    this.G = G(a)
}
y(hs, O);
function nA() {
    Q.apply(this, arguments)
}
y(nA, Q);
v = nA.prototype;
v.la = n();
v.Za = function() {
    var a = new Yz
      , c = new hs;
    Zz(a, c, new aA);
    return a
}
;
v.Pb = function() {
    return new jA
}
;
v.mc = n();
v.bb = function() {
    return ih()
}
;
v.lc = aa(!1);
function oA() {}
oA.prototype.g = n();
function pA() {
    Yz.call(this)
}
y(pA, Yz);
var qA = new Uz("high_frequency_builder");
function rA(a, c, d) {
    a = new jp(a);
    R(d, a);
    var e = new np(d);
    R(d, e);
    qp(e, a, "tick", c);
    a.start()
}
;function sA() {
    Yz.call(this)
}
y(sA, Yz);
function tA(a, c, d) {
    var e = 1E3 * Date.now();
    if (0 == c) {
        c = new Xz;
        var f = new Wz;
        f = K(f, 1, e);
        I(c, Wz, 1, f);
        N(c, 3, 1);
        I(a.g, Xz, 8, c);
        K(a.g, 12, d);
        K(a.g, 13, d);
        K(a.g, 4, e);
        K(a.g, 3, d)
    } else
        1 == c && (c = new Xz,
        f = new Vz,
        e = K(f, 1, e),
        I(c, Vz, 2, e),
        N(c, 3, 2),
        I(a.g, Xz, 8, c),
        K(a.g, 12, d),
        K(a.g, 3, d));
    return a
}
var uA = new Uz("system_builder");
function vA(a, c) {
    if (c && a in c)
        return a;
    a = "webkit" + Ng(a);
    return void 0 === c || a in c ? a : null
}
;function wA() {
    Io.call(this, "visibilitychange")
}
y(wA, Io);
var xA = new WeakMap;
function yA(a) {
    function c(g) {
        var h = ha(g);
        g = h.next().value;
        h = ia(h);
        return a.apply(g, h)
    }
    function d(g) {
        g = ha(g);
        g.next();
        g = ia(g);
        return e(f, g)
    }
    var e = void 0 === e ? zA : e;
    var f = Da(a);
    return function() {
        var g = qa.apply(0, arguments)
          , h = this || z
          , k = xA.get(h);
        k || (k = {},
        xA.set(h, k));
        return Ma(k, [this].concat(ja(g)), c, d)
    }
}
function zA(a, c) {
    a = [a];
    for (var d = c.length - 1; 0 <= d; --d)
        a.push(typeof c[d], c[d]);
    return a.join("\v")
}
;function AA(a) {
    Y.call(this);
    a || (a = vb || (vb = new Pg));
    this.g = a;
    if (this.o = this.Vc())
        this.v = Yo(this.g.g, this.o, A(this.Zc, this))
}
Ka(AA, Y);
v = AA.prototype;
v.Vc = yA(function() {
    var a = !!this.eb()
      , c = "hidden" != this.eb();
    if (a) {
        var d;
        c ? d = "webkitvisibilitychange" : d = "visibilitychange";
        a = d
    } else
        a = null;
    return a
});
v.eb = yA(function() {
    return vA("hidden", this.g.g)
});
v.Xc = yA(function() {
    return vA("visibilityState", this.g.g)
});
v.Zc = function() {
    var a = this.eb() ? this.g.g[this.Xc()] : null;
    a = new wA(!!this.g.g[this.eb()],a);
    this.dispatchEvent(a)
}
;
v.K = function() {
    gp(this.v);
    AA.ua.K.call(this)
}
;
function BA(a, c) {
    Q.call(this);
    this.j = a;
    this.g = new AA(c);
    R(this, this.g);
    this.o = new np(this);
    R(this, this.o);
    this.g.eb() && qp(this.o, this.g, "visibilitychange", this.v)
}
y(BA, Q);
BA.prototype.v = function() {
    if (this.j.lc()) {
        var a = this.g;
        a = !!a.g.g[a.eb()];
        a = this.j.Za(a ? 102001 : 102E3, 0);
        this.j.la(a)
    }
}
;
function CA(a, c, d) {
    d = void 0 === d ? !1 : d;
    Q.call(this);
    this.g = a;
    this.j = c;
    R(this, this.j);
    this.o = d
}
y(CA, Q);
v = CA.prototype;
v.la = function(a) {
    var c = this.g;
    K(a.g, 6, c.o);
    a = $z(a);
    c.g.add(a);
    c.v = !0;
    c = this.j;
    3 <= c.g.g.g.length && c.j.j()
}
;
v.Za = function(a, c) {
    a = tA(DA(this.g, a), c, this.g.C++);
    1 == c && (c = this.g,
    kf(H(a.g, Xz, 8), 3),
    c.B.add(a));
    return a
}
;
v.Pb = function() {
    return this.g.j
}
;
v.mc = function() {
    var a = this.g
      , c = EA(a, 716);
    FA(a, c);
    c = $z(c);
    a.g.add(c);
    a.L = !0;
    a.D = !0;
    a = this.j;
    rA(a.B, a.j.j, a.j);
    rA(36E5, a.F, a);
    this.j.j.j();
    this.o && new BA(this)
}
;
v.bb = function() {
    this.j.v();
    return nh(Array.from(this.j.o)).then()
}
;
v.lc = function() {
    var a = this.g;
    return a.L && a.D && !0
}
;
function GA(a, c, d) {
    Q.call(this);
    this.B = null != d ? a.bind(d) : a;
    this.A = c;
    this.o = null;
    this.v = !1;
    this.g = null
}
y(GA, Q);
GA.prototype.j = function(a) {
    this.o = arguments;
    this.g ? this.v = !0 : HA(this)
}
;
GA.prototype.stop = function() {
    this.g && (z.clearTimeout(this.g),
    this.g = null,
    this.v = !1,
    this.o = null)
}
;
GA.prototype.K = function() {
    Q.prototype.K.call(this);
    this.stop()
}
;
function HA(a) {
    a.g = kp(function() {
        a.g = null;
        a.v && (a.v = !1,
        HA(a))
    }, a.A);
    var c = a.o;
    a.o = null;
    a.B.apply(null, c)
}
;function IA(a, c, d, e, f) {
    Q.call(this);
    this.g = a;
    this.D = c;
    this.j = new GA(this.v,3E3,this);
    this.o = new Set;
    this.A = e;
    this.B = f || 6E4
}
y(IA, Q);
IA.prototype.v = function() {
    var a = this;
    if (0 != this.g.g.g.length && (!this.A || this.g.v)) {
        var c = JA(this.g)
          , d = this.D.g(c);
        d && (rh(d, function() {
            return void a.o.delete(d)
        }),
        this.o.add(d))
    }
}
;
IA.prototype.F = function() {
    var a = this.g
      , c = EA(a, 1153);
    c = $z(c);
    a.g.add(c);
    this.j.j()
}
;
function KA() {}
KA.prototype.wc = function() {
    return new pA
}
;
function LA() {
    this.g = []
}
LA.prototype.add = function(a) {
    this.g.push(a)
}
;
function MA() {
    this.g = {}
}
MA.prototype.add = function(a) {
    kf(H(a.g, Xz, 8), 3);
    var c = gf(a.g, 12);
    this.g[c] = a
}
;
function NA(a) {
    this.G = G(a, 500)
}
y(NA, O);
function ur(a, c) {
    M(a, 6, c)
}
NA.ia = [1];
function OA() {
    var a = PA.g;
    this.j = PA.j;
    this.F = a;
    this.C = 1;
    this.A = this.o = null;
    this.B = new MA;
    this.g = new LA;
    this.D = this.L = this.v = !1
}
function DA(a, c) {
    a = Zz(new Yz, new hs, a.F);
    var d = a.j.g[uA.R()].wc();
    Zz(d, a.g, a.j);
    K(d.g, 10, c);
    return d
}
function JA(a) {
    var c = a.g
      , d = c.g;
    c.g = [];
    c = new NA;
    var e = sf(a.j.g);
    c = I(c, eA, 2, e);
    e = a.j;
    mA(e);
    (e = e.o ? sf(e.o) : null) && I(c, iA, 5, e);
    var f;
    e = a.j;
    for (var g, h = d.length - 1; 0 <= h; h--) {
        var k = H(d[h], ds, 5);
        if (k && H(k, Hr, 1)) {
            k = H(k, Hr, 1);
            null != Ye(k, 12) && void 0 === f && (f = Ye(k, 12));
            k = H(k, Gr, 20);
            if (void 0 !== k && void 0 === g) {
                g = new bA;
                var l = Ye(k, 2);
                void 0 !== l && J(g, 2, l);
                k = Ye(k, 1);
                void 0 !== k && J(g, 1, k)
            }
            if (void 0 !== f && void 0 !== g)
                break
        }
    }
    e = e.j ? sf(e.j) : null;
    if (void 0 !== f || void 0 !== g)
        e || (e = new cA),
        void 0 !== f && J(e, 6, f),
        void 0 !== g && I(e, bA, 13, g);
    (f = e) && I(c, cA, 3, f);
    a = sf(a.j.A);
    I(c, dA, 4, a);
    ff(c, hs, 1, d);
    return c
}
function EA(a, c) {
    var d = tA(DA(a, c), 0, a.C++);
    var e = a.B;
    var f = Object.keys(e.g);
    if (0 == f.length)
        e = null;
    else {
        for (var g = [], h = 0; h < f.length; h++) {
            var k = Number(f[h])
              , l = e.g[k]
              , m = new Or;
            k = K(m, 1, k);
            l = gf(l.g, 10);
            l = K(k, 2, null == l ? void 0 : l);
            g.push(l)
        }
        e = g
    }
    716 != c && (c = a.A,
    K(d.g, 6, a.o),
    f = new Pr,
    c = K(f, 1, c),
    e && ff(c, Or, 2, e),
    e = Qy(d),
    I(e, Pr, 3, c));
    FA(a, d);
    return d
}
function FA(a, c) {
    a.o = gf(c.g, 12);
    a.A = gf(H(H(c.g, Xz, 8), Wz, 1), 1)
}
;function QA() {}
QA.prototype.wc = function() {
    return new sA
}
;
function RA() {
    this.g = this.j = null
}
;function SA() {
    this.o = this.v = null;
    this.g = new jA;
    this.j = !1
}
;function TA(a, c, d, e, f, g) {
    c = UA(a, 1E5, c);
    var h = cs(es(Qy(c)));
    d = Yr(J(h, 4, !0), d);
    e = J(d, 8, e);
    Zr(e, g);
    null != f && M(h, 11, f);
    a.la(c)
}
function VA(a, c, d, e, f) {
    var g = Promise.resolve(null)
      , h = Promise.resolve(null);
    c && (a = Promise.resolve(Vu(a)),
    g = a.then(function(k) {
        return WA(k, c)
    }),
    h = a.then(function(k) {
        return XA(k, c)
    }));
    return Promise.all([g, h]).then(function(k) {
        var l = ha(k);
        k = l.next().value;
        var m = l.next().value;
        l = UA(d, 100003, e);
        var p = new Tr;
        if (null != f) {
            var r = new js(f);
            I(p, Nr, 1, r.j);
            r = wi(f, "dods");
            (r = Wn(r)) && N(p, 2, r);
            r = wi(f, "eops");
            r = !r || "1" != r && "0" != r ? null : "1" == r;
            null != r && J(p, 6, r);
            r = Xn(f);
            r.length && cf(p, 4, r, re);
            null != k && N(p, 3, k);
            null != m && m.length && ff(p, Bo, 5, m)
        }
        k = es(Qy(l));
        I(k, Tr, 5, p);
        d.la(l);
        return d.bb()
    })
}
function YA(a, c, d) {
    c = UA(a, 100004, c);
    Zr(cs(es(Qy(c))), d);
    a.la(c)
}
function ZA(a) {
    switch (a) {
    case "cache-storage":
        return 1;
    case "client-redirect":
        return 5;
    case "network":
        return 2;
    case "none":
        return 6;
    default:
        return null
    }
}
function $A(a) {
    switch (a) {
    case "scary":
        return 3;
    case "canary":
        return 2;
    case "prod":
        return 1;
    default:
        return 0
    }
}
function WA(a, c) {
    return Sh(om(a.j.fc(), c)).then(function(d) {
        return null != d ? d.g : null
    })
}
function XA(a, c) {
    return Sh(fm(a.j.ec(), c)).then(function(d) {
        return d.map(function(e) {
            var f = new Bo;
            f = qf(f, 2, e.j);
            return N(f, 1, e.o)
        })
    })
}
var aB = [/\/document\/client\/css\/.*\bKixCss_(ltr|rtl)\.css$/, /\/spreadsheets2\/client\/css\/.*\bwaffle.*(ltr|rtl)\.css$/, /\/(presentation|drawings)\/client\/css\/.*\beditor_css.*(ltr|rtl)\.css$/]
  , bB = [/\/document\/client\/js\/.*\bclient_js_.*core(__.+)?\.js$/, /\/spreadsheets2\/client\/js\/.*\bwaffle.*core(__.+)?\.js$/, /\/(presentation|drawings)\/client\/js\/.*\beditor.*core(__.+)?\.js$/]
  , cB = [/\/document\/client\/js\/.*\bclient_js_.*app(__.+)?\.js$/, /\/spreadsheets2\/client\/js\/.*\bwaffle.*shell(__.+)?\.js$/, /\/(presentation|drawings)\/client\/js\/.*\beditor.*app(__.+)?\.js$/];
function dB(a) {
    return aB.some(function(c) {
        return c.test(a)
    }) ? 1 : bB.some(function(c) {
        return c.test(a)
    }) ? 2 : cB.some(function(c) {
        return c.test(a)
    }) ? 3 : $x(a) ? 14 : ay(a) ? 13 : null
}
function UA(a, c, d) {
    a = a.Za(c, 0);
    c = new bs;
    var e = new Xr;
    I(c, Xr, 1, e);
    var f = Qy(a);
    I(f, bs, 50, c);
    M(e, 1, d);
    d = new Tq;
    I(c, Tq, 2, d);
    (c = z.navigator.connection) && c.effectiveType && N(d, 3, Uq(c.effectiveType));
    return a
}
;function eB(a, c) {
    var d = fB;
    this.j = a;
    this.g = d;
    this.o = c
}
function gB(a, c, d, e) {
    if ("document-not-available-locally" == e.j) {
        var f = VA(a.o, c.T ? c.T.Pa : null, a.j, c.clientId, c.ga.url);
        a = hB(a.g, c, f);
        60 <= Nc() && c.waitUntil(a)
    }
    a: if (null == d.ta || d.Ha && !e.Ha) {
        if (e.g && (f = hk(e.g, "pendingQueueState"),
        a = "server-document-deleted" == d.j,
        f = null != f && iB.includes(f),
        a && !f)) {
            a = !1;
            break a
        }
        a = !0
    } else
        a = !1;
    if (a) {
        if ((a = d.j) && e.g && (Kz(e, a),
        "server-suggested" == a)) {
            f = c.T.ya;
            a = Cz(e);
            var g = Bn(a).ouri || null;
            g && (g = zo(g, "ofip"),
            c = c.ga.url,
            Ao.includes(f) && wi(c, "rr") && (g = zo(g, "pru"),
            c = g = zo(g, "rr"),
            (g = ki(ji(c)[5] || null)) && g.endsWith(f) && (f = g.substring(0, g.length - f.length) + "/edit",
            lc(f, "/") || (f = "/" + f),
            c = ji(c),
            c = hi(c[1], c[2], c[3], c[4], f, c[6], c[7])),
            g = c),
            c = g,
            f = Bn(a),
            f.ouri = c,
            c = Dn(a, f),
            Dz(e, c))
        }
        (d = d.Wa) && Ez(e, d);
        return e
    }
    (e = e.Wa) && Ez(d, e);
    return d
}
var iB = [0, 2];
function jB(a, c, d, e, f, g) {
    this.C = a;
    this.A = c;
    this.o = d;
    this.j = e;
    this.g = f;
    this.v = g
}
jB.prototype.fetch = function(a) {
    var c = this, d = kB(this.C, a), e = null, f = kB(this.A, a).then(function(k) {
        var l = k.Wa;
        l && py(c.o, a, l, {
            serviceworker_localResponseFlakyConnectionError: "true"
        });
        return e = k
    }), g, h = lp(4E3).then(function() {
        if (61 <= Nc()) {
            var k = z.navigator.connection;
            k = lB.indexOf(k && k.effectiveType ? k.effectiveType : "4g");
            var l = lB.indexOf("2g");
            k = 0 <= k && k <= l
        } else
            k = !1;
        if (k)
            g = 1;
        else {
            if (z.navigator.onLine)
                return lp(18E3);
            g = 2
        }
    }).then(function() {
        return f
    });
    return Promise.race([d, h]).then(function(k) {
        if (k != e) {
            var l = c.j
              , m = UA(l, 100011, a.clientId);
            l.la(m);
            return mB(c, a, k, f)
        }
        g = g || 3;
        k = c.j;
        l = !e.Ha;
        m = a.T.ya;
        var p = g
          , r = UA(k, 100002, a.clientId)
          , u = cs(es(Qy(r)));
        J(u, 3, l);
        J(u, 4, !0);
        Yr(u, m);
        N(u, 9, p);
        k.la(r);
        return nB(c, a, d, e, g)
    })
}
;
function mB(a, c, d, e) {
    return d.Ha ? e.then(function(f) {
        return gB(a.g, c, d, f)
    }) : Promise.resolve(d)
}
function nB(a, c, d, e, f) {
    if (!e.Ha && e.g) {
        if (d = oB(a.v, c.clientId))
            d.V = !0;
        Kz(e, "flaky-connection-pre-response");
        Lz(e, f);
        return Promise.resolve(e)
    }
    return d.then(function(g) {
        return gB(a.g, c, g, e)
    })
}
var lB = ["slow-2g", "2g", "3g", "4g"];
function pB() {
    this.B = this.I = this.A = this.L = this.j = this.o = this.H = this.S = this.F = this.J = this.D = this.Bc = this.Cc = this.g = this.vb = this.P = this.C = this.v = null;
    this.V = !1;
    this.O = this.M = null;
    this.vc = []
}
pB.prototype.Lb = function(a) {
    this.P = a
}
;
pB.prototype.start = function() {
    this.v = Date.now()
}
;
function qB(a, c) {
    switch (c) {
    case "cache-storage":
        return a.L;
    case "network":
        return a.Bc;
    default:
        return null
    }
}
function rB(a, c) {
    switch (c) {
    case "cache-storage":
        return sB(a.o, a.j, a.L, qB(a, c), a.A);
    case "network":
        return sB(a.vb, a.g, a.Cc, qB(a, c), a.D);
    default:
        throw Error("Lc`" + c);
    }
}
function sB(a, c, d, e, f) {
    if (!a)
        return null;
    var g = new $r;
    K(g, 1, 1E3 * a);
    null != c && K(g, 2, 1E3 * c);
    null != d && J(g, 4, d);
    null != e && J(g, 3, e);
    null != f && J(g, 5, f);
    return g
}
;function tB(a, c, d, e, f, g, h) {
    this.ga = a;
    this.o = c;
    this.clientId = e;
    this.g = f;
    this.j = g;
    this.U = new pB;
    this.preloadResponse = Promise.resolve(h);
    this.T = d
}
tB.prototype.waitUntil = function(a) {
    this.o(a)
}
;
function uB(a) {
    return a.g && !!a.T && a.T.v
}
;function vB(a, c) {
    this.j = a;
    this.g = void 0 === c ? null : c
}
function wB(a, c) {
    var d = c.request
      , e = "navigate" == d.mode
      , f = a.g ? a.g.ob(d.url) : null
      , g = jy(d.url);
    d = new tB(d,function(k) {
        return c.waitUntil(k)
    }
    ,f,c.resultingClientId || c.clientId || null,e,g,ed && 0 <= wc() ? c.preloadResponse : void 0);
    g = !!c.resultingClientId;
    var h = 72 <= Nc() && !g;
    !f || f.o || e && !h || (e = Error("Mc"),
    xy(e),
    py(a.j, d, e, {
        serviceworker_hasResultingClientId: String(g)
    }));
    return d
}
;function xB(a, c, d, e) {
    var f = yB;
    this.A = a;
    this.g = c;
    this.v = d;
    this.o = f;
    this.j = e
}
xB.prototype.fetch = function(a) {
    var c = this
      , d = a.T;
    return Promise.resolve(Yu(this.A)).then(function(e) {
        var f = e.g;
        e = e.j;
        var g = c.o;
        g = new Map([[g.getType(), g]]);
        g = new Vw(ik(e, "locale"),new Ew(g),g);
        return d.kc ? zB(c, f, e, d, g) : d.Ob ? AB(c, a, f, e, d, g) : d.Pa ? BB(c, a, f, e, d, g) : Promise.reject(Error("Nc"))
    })
}
;
function zB(a, c, d, e, f) {
    return CB(c, e).then(function(g) {
        if (!g || e.o)
            return new Bz(null,"none",!0);
        g = Yw(f, d, e.g, e.ya, g.sa());
        return nz(a.g, g).then(function(h) {
            return h ? new Bz(h.g,"cache-storage",!1) : new Bz(null,"cache-storage",!0)
        })
    })
}
function DB(a, c, d, e, f) {
    return CB(c, e).then(function(g) {
        if (!g)
            return Gz("none");
        g = g.sa() || T(a.j, "jobset");
        var h = Mw(a.o, g, tm(d), ik(d, "locale"), d.R(), f, e.Pa);
        return nz(a.g, h).then(function(k) {
            var l;
            k ? l = new Bz(Jz(h),"cache-storage",!0,"document-not-available-locally") : l = Gz("cache-storage");
            return l
        })
    })
}
function AB(a, c, d, e, f, g) {
    d = new sn(e,d,new lj(a.v),a.j);
    if (f.o)
        return Promise.reject(Error("Oc"));
    var h = zn(d, f.g);
    return (new Promise(function(k, l) {
        Th(h, k, l)
    }
    )).then(function(k) {
        return EB(a, c, e, f, g, k)
    })
}
function BB(a, c, d, e, f, g) {
    c.U.J = Date.now();
    return (new Promise(function(h) {
        wt(d.j.C, f.Pa, h)
    }
    )).then(function(h) {
        var k = c.U;
        k.F = Date.now() - k.J;
        return h ? EB(a, c, e, f, g, h) : DB(a, d, e, f, c.ga.url)
    })
}
function EB(a, c, d, e, f, g) {
    var h = e.Ob ? Ww(f, g, d, 2, e.ya, void 0, e.A || void 0) : Ww(f, g, d, 4, e.ya, c.ga.url);
    c.U.S = Date.now();
    return nz(a.g, h).then(function(k) {
        var l = c.U;
        l.H = Date.now() - l.S;
        if (k)
            if (!0 === jk(g, "modelNeedsResync"))
                k = Iz(h, g, "document-model-needs-resync");
            else {
                var m;
                mf(k.j, 1) ? m = Iz(h, g, "cache-needs-update") : m = new Bz(Jz(h),"cache-storage",!1,void 0,g);
                k = m
            }
        else
            k = Fz("cache-storage", new Kv(h));
        return k
    })
}
function CB(a, c) {
    return c.o ? Promise.reject(Error("Oc")) : new Promise(function(d, e) {
        xn(a.j.Xa(), c.g, d, e)
    }
    )
}
;function FB(a, c, d, e) {
    e = void 0 === e ? 0 : e;
    this.o = a;
    this.v = c;
    this.g = isNaN(e) ? 0 : e;
    this.j = d
}
FB.prototype.fetch = function(a) {
    var c = this
      , d = 0 == this.g
      , e = d ? Promise.resolve() : Promise.resolve(lp(Math.abs(this.g))).then(function() {
        d = !0
    })
      , f = new GB(this.o)
      , g = new GB(this.v)
      , h = 0 <= this.g ? f : g
      , k = 0 <= this.g ? g : f
      , l = h.fetch(a)
      , m = Promise.race([l, e]).then(function() {
        return h.g && !h.g.Ha ? null : k.fetch(a)
    });
    return Promise.race([l, m]).then(function(p) {
        var r = p == h.g ? m : l;
        return p.Ha ? r.then(function() {
            return gB(c.j, a, g.g, f.g)
        }) : (d && a.U.vc.push(r),
        p)
    })
}
;
function GB(a) {
    this.j = a;
    this.g = null
}
GB.prototype.fetch = function(a) {
    var c = this;
    return kB(this.j, a).then(function(d) {
        return c.g = d
    })
}
;
function HB(a, c, d, e) {
    this.o = a;
    this.v = c;
    this.g = d;
    this.j = e
}
HB.prototype.fetch = function(a) {
    var c = this;
    return kB(this.o, a).then(function(d) {
        return d.Ha ? kB(c.v, a).then(function(e) {
            return gB(c.j, a, c.g ? e : d, c.g ? d : e)
        }) : d
    })
}
;
function IB(a, c, d) {
    this.o = a;
    this.g = c;
    this.j = d
}
IB.prototype.fetch = function(a) {
    var c = this
      , d = a.ga;
    a.U.vb = Date.now();
    return a.preloadResponse.then(function(e) {
        a.U.Lb(!!e);
        return e ? e : c.o.fetch(d)
    }).catch(function(e) {
        e = Ei(e);
        if (a.T && z.navigator.onLine && !e.message.includes("The service worker navigation preload request was cancelled before 'preloadResponse' settled.")) {
            var f = {};
            py(c.g, a, e, (f.serviceworker_nativeFetchOrPreloadError = "true",
            f))
        }
        return null
    }).then(function(e) {
        var f = a.U;
        f.D || (f.g = Date.now() - f.vb,
        f.D = !1);
        a.U.Cc = !!e;
        if (f = !!e)
            f = z.performance.getEntriesByName(a.ga.url),
            0 == f.length ? f = null : (f = f[f.length - 1].transferSize,
            f = null == f ? null : 0 == f);
        null != f && (a.U.Bc = f);
        var g;
        e ? g = JB(c, a, e) : g = new Bz(null,"network",!0,"offline");
        return g
    })
}
;
function JB(a, c, d) {
    if (c.T && c.T.Pa) {
        var e = d.status
          , f = d.headers;
        c = wi(c.ga.url, "fws");
        if (404 == e)
            return Hz(d, "server-document-not-found");
        if (410 == e && S(a.j, "docs-sw-eddf"))
            return Hz(d, "server-document-deleted");
        if ("true" != c) {
            if (KB.includes(e))
                return Hz(d, "server-error");
            if ("true" == f.get("docs-offline-fallback-if-possible"))
                return Hz(d, "server-suggested")
        }
    }
    return new Bz(d,"network",!1)
}
var KB = [500, 502, 503];
function LB(a, c, d) {
    var e = yB;
    this.o = a;
    this.g = c;
    this.v = e;
    this.j = d
}
function MB(a) {
    return Promise.resolve(ps(a.o)).then(function(c) {
        if (!c)
            return null;
        var d = T(a.j, "jobset") || "prod";
        c = c.j;
        d = Kw(a.v, d, tm(c), ik(c, "locale"), c.R());
        return nz(a.g, d).then(function(e) {
            return e ? e.g : null
        })
    })
}
;function NB(a, c) {
    var d = c.request;
    if ("GET" == d.method) {
        var e = wB(a.O, c)
          , f = d.url;
        "worker" !== d.destination || f.includes((new bo(zi(a.v.Ya, "/"))).toString()) || f.includes("/offline/synctaskworker.js") || f.includes("/offline/eventbusworker.js") || (f = Error("Pc"),
        xy(f),
        py(a.A, e, f, {
            target_url: d.url
        }));
        if (OB(a, e))
            c.respondWith(new Response(null,{
                status: 204,
                statusText: "Disabled By Service Worker"
            }));
        else {
            PB(a.g, e);
            e.U.start();
            if (e.j)
                d = QB(a, e);
            else if (e.T)
                d = RB(a, e, e.T);
            else if (e.g)
                d = kB(a.j, e);
            else
                return;
            c.respondWith(SB(a.C, e, d.then(function(g) {
                TB(a, e, g);
                UB(a, e, Promise.resolve(lp(0)).then(function() {
                    return VB(a, e, g)
                }));
                return g
            }), a.H))
        }
    }
}
function RB(a, c, d) {
    if (d.j)
        return a.B.fetch(c);
    var e = c.ga.url
      , f = "true" == wi(e, "fws");
    e = !f && (a.J || "true" == wi(e, "fcs"));
    if (d.v && c.g) {
        dz(a.D);
        var g = oB(a.g, c.clientId);
        TA(a.o, c.clientId, d.ya, f, d.Pa || null, !!g);
        g && !g.C && (g.start(),
        WB(g, d.ya),
        UB(a, c, XB(g).then(function() {
            return a.o.bb()
        })))
    }
    var h = a.I && "iframe" === c.ga.destination ? a.j : e ? a.P : !d.Pa || f ? a.S : a.M;
    return a.L.clients.matchAll().then(function(k) {
        c.U.I = k.length
    }).then(function() {
        return h.fetch(c)
    })
}
function QB(a, c) {
    var d = dB(c.ga.url);
    d && (c.U.B = d);
    d = oB(a.g, c.clientId);
    return (d && d.D ? a.B : a.F).fetch(c)
}
function TB(a, c, d) {
    c.U.C = Date.now();
    if (uB(c)) {
        var e = a.o
          , f = UA(e, 100012, c.clientId);
        e.la(f)
    }
    if ((a = oB(a.g, c.clientId)) && c.g) {
        a.I.push(c);
        e = !!c.T && c.T.j;
        c.T && c.T.v && (a.D = e || !!d.g);
        if (d = !a.B)
            f = c.U,
            qf(a.v, 7, f.I),
            a.v.Lb(f.P),
            K(a.A, 3, f.v),
            K(a.A, 4, f.C),
            null != f.g && (gf(a.g, 1),
            K(a.g, 1, f.g)),
            null != f.F && (gf(a.g, 2),
            K(a.g, 2, f.F)),
            null != f.H && (gf(a.g, 3),
            K(a.g, 3, f.H)),
            a.B = !0;
        !a.M && e && (c = c.U,
        K(a.A, 5, c.v),
        K(a.A, 6, c.C),
        null != c.j && (gf(a.g, 4),
        K(a.g, 4, c.j)),
        a.M = !0,
        J(a.v, 5, !d))
    }
}
function VB(a, c, d) {
    uB(c) && d.ta && 200 == d.ta.status && UB(a, c, Promise.resolve(lp(1E4)));
    return YB(a, c, d).then(function() {
        return ZB(a, c, d)
    }).then(function() {
        return a.o.bb()
    })
}
function YB(a, c, d) {
    return uB(c) ? Promise.resolve().then(function() {
        var e = oB(a.g, c.clientId);
        return (e = e ? e.o : null) && e.g ? $B(e) : null
    }).then(function(e) {
        var f = oB(a.g, c.clientId)
          , g = d.ta ? d.ta.status : null;
        f && (f.S = !0,
        f.W = e,
        f.fa = g);
        var h = a.o
          , k = c.U.g
          , l = d.o
          , m = d.ta ? d.ta.type : null
          , p = c.T.ya
          , r = UA(h, 100001, c.clientId)
          , u = cs(es(Qy(r)));
        null != k && K(u, 2, 1E3 * k);
        null != l && (k = ZA(l)) && N(u, 12, k);
        null != g && qf(u, 5, g);
        null != m && M(u, 7, m);
        null != e && (g = new Vr,
        e = J(g, 2, e),
        I(u, Vr, 10, e));
        Zr(Yr(J(u, 4, !0), p), !!f);
        h.la(r)
    }) : Promise.resolve()
}
function ZB(a, c, d) {
    var e = c.U.B;
    if (e) {
        var f = qB(c.U, d.o)
          , g = c.U.V
          , h = c.U.v
          , k = c.U.C;
        return Promise.race([Promise.all(c.U.vc), lp(3E4)]).catch(function(l) {
            py(a.A, c, Ei(l))
        }).then(function() {
            var l = c.U
              , m = Date.now();
            l.vb && null == l.g && (l.g = m - l.vb,
            l.D = !0);
            l.o && null == l.j && (l.j = m - l.o,
            l.A = !0);
            l = a.o;
            var p = c.clientId
              , r = 1E3 * h
              , u = 1E3 * k
              , w = d.o
              , F = rB(c.U, "cache-storage")
              , L = rB(c.U, "network")
              , ra = c.U.M
              , cb = c.U.O
              , Aa = !!oB(a.g, c.clientId);
            m = l.Za(100005, 0);
            var bd = new bs
              , ub = new as;
            null != f && J(ub, 1, f);
            J(ub, 5, g);
            N(ub, 2, e);
            K(ub, 3, r);
            K(ub, 4, u);
            (r = ZA(w)) && N(ub, 6, r);
            F && I(ub, $r, 7, F);
            L && I(ub, $r, 8, L);
            null != ra && qf(ub, 9, ra);
            null != cb && qf(ub, 10, cb);
            F = I(bd, as, 3, ub);
            L = new Xr;
            p = M(L, 1, p);
            Aa = Zr(p, Aa);
            I(F, Xr, 1, Aa);
            Aa = Qy(m);
            I(Aa, bs, 50, bd);
            l.la(m)
        })
    }
    return Promise.resolve()
}
function UB(a, c, d) {
    a = hB(a.C, c, d);
    60 <= Nc() && c.waitUntil(a)
}
function OB(a, c) {
    var d = c.ga;
    return !c.T && c.g && "/preload" == Ow(a.v, d.url)
}
;function aC() {
    var a = bC
      , c = cC
      , d = dC;
    this.o = eC;
    this.j = a;
    this.g = c;
    this.v = d
}
function fC(a, c) {
    gC(a.v);
    var d = Promise.resolve().then(function() {
        var e = a.o.registration.navigationPreload;
        if (e)
            return (ed && 0 <= wc() ? e.enable() : e.disable()).catch(function(f) {
                return uy(a.g, Ei(f))
            })
    }).then(function() {
        return a.o.clients.claim()
    }).catch(function(e) {
        return uy(a.g, Ei(e))
    }).finally(function() {
        return wp(a.j.A)
    });
    c.waitUntil(Promise.resolve(wq(a.j, d)))
}
;function hC() {
    var a = bC
      , c = iC
      , d = cC
      , e = jC
      , f = !(!kC || !lC);
    this.o = eC;
    this.A = a;
    this.v = c;
    this.j = d;
    this.g = e;
    this.C = f
}
function mC(a, c) {
    var d = a.o.registration.active ? "reinstall" : "new_install"
      , e = {}
      , f = (e.serviceworker_cacheUpdateReason = d,
    e)
      , g = !0
      , h = !1;
    e = ih().then(function() {
        if (a.C || "reinstall" !== d)
            return f.serviceworker_cacheUpdateDuringSwInstall = "true",
            fz(a.v, d).catch(function(k) {
                "new_install" === d && ty(a.j, Ei(k), "install", f)
            });
        f.serviceworker_cacheUpdateDuringSwInstall = "false";
        h = !0
    }).then(function() {
        return a.o.skipWaiting()
    }).Aa(function(k) {
        sy(a.j, Ei(k), f);
        g = !1
    }).then(function() {
        var k = a.g.Za(100008, 0)
          , l = Qy(k)
          , m = new bs;
        var p = new Ur;
        p = J(p, 1, g);
        p = J(p, 2, h);
        m = I(m, Ur, 7, p);
        I(l, bs, 50, m);
        a.g.la(k);
        if (!g)
            return Promise.reject(Error("Qc"))
    });
    c.waitUntil(Promise.resolve(e).finally(function() {
        return Promise.all([wp(a.A.A), a.g.bb()])
    }))
}
;function nC(a) {
    this.g = a
}
;function oC(a) {
    this.G = G(a)
}
y(oC, O);
function pC(a) {
    this.G = G(a)
}
y(pC, O);
function qC(a, c) {
    return M(a, 1, c)
}
function rC(a, c) {
    return ff(a, oC, 2, c)
}
pC.ia = [2];
function sC(a) {
    this.G = G(a)
}
y(sC, O);
function tC(a) {
    this.G = G(a)
}
y(tC, O);
tC.prototype.getType = function() {
    return pf(this, 1)
}
;
function uC(a) {
    this.G = G(a)
}
y(uC, O);
uC.prototype.Lb = function(a) {
    J(this, 3, a)
}
;
uC.prototype.sa = function() {
    return pf(this, 10)
}
;
function vC(a) {
    this.G = G(a)
}
y(vC, O);
function wC(a) {
    this.G = G(a)
}
y(wC, O);
function xC(a) {
    this.G = G(a)
}
y(xC, O);
function yC(a, c) {
    I(a, uC, 1, c)
}
function zC(a, c) {
    I(a, wC, 2, c)
}
function AC(a, c) {
    I(a, vC, 3, c)
}
;function BC(a) {
    this.G = G(a)
}
y(BC, O);
function CC(a, c) {
    return I(a, xC, 1, c)
}
;function DC(a) {
    this.G = G(a)
}
y(DC, O);
function EC(a) {
    this.G = G(a)
}
y(EC, O);
function FC(a) {
    this.G = G(a)
}
y(FC, O);
function GC(a) {
    this.G = G(a)
}
y(GC, O);
function HC(a) {
    this.G = G(a)
}
y(HC, O);
function IC(a, c) {
    var d = c.g;
    if (a.g[d])
        throw Error("Sc`" + d);
    a.g[d] = c;
    return a
}
function JC(a, c) {
    if (c && c.data && c.ports.length) {
        var d = new tC(c.data)
          , e = c.ports[0];
        a = KC(a.o, d, LC(a, d, c.source && c.source.id ? c.source.id : null).then(function(f) {
            return e.postMessage(Le(f, Me(f.G), !0))
        }));
        "function" === typeof c.waitUntil && c.waitUntil(a)
    } else
        vy(a.j, Error("Tc"))
}
function LC(a, c, d) {
    MC(a.v, kf(c, 1));
    return NC(a, c, d).Aa(function(e) {
        e = Ei(e);
        vy(a.j, e, c);
        return OC(e)
    })
}
function OC(a) {
    var c = void 0 === c ? {} : c;
    var d = new HC
      , e = Object.keys(c).map(function(f) {
        var g = new oC;
        g = M(g, 1, f);
        return M(g, 2, c[f])
    });
    e = rC(qC(new pC, a.message), e);
    "cache update timed out" === a.message && N(e, 3, 1);
    I(d, pC, 3, e);
    return d
}
function NC(a, c, d) {
    var e = kf(c, 1);
    a = a.g[e];
    return a ? kf(c, 1) !== a.g ? jh(Error("Rc`" + a.g)) : a.j(c, d) : (c = Error("Uc`" + e),
    xy(c),
    jh(c))
}
;function PC(a, c) {
    this.g = 7;
    this.v = a;
    this.o = c
}
y(PC, nC);
PC.prototype.j = function() {
    var a = this.o;
    if (a = a.H ? a.v : Error("Fc")) {
        var c = {};
        ty(this.v, a, "messageHandler", (c.serviceworker_messageHandler_requestType = 0,
        c));
        return ih(OC(a))
    }
    return ih(new HC)
}
;
function QC(a) {
    this.g = 1;
    this.o = a
}
y(QC, nC);
QC.prototype.j = function() {
    var a = this;
    return ih().then(function() {
        return jz(a.o)
    }).then(function() {
        return new HC
    })
}
;
function RC(a, c, d) {
    this.g = 3;
    this.v = a;
    this.o = c;
    this.A = d
}
y(RC, nC);
RC.prototype.j = function(a, c) {
    var d = this;
    return SC(this.o, c).then(function(e) {
        var f = oB(d.o, c), g = f ? f.I.slice() : [], h = g.some(function(r) {
            return !r.T
        }), k;
        mf(H(e, uC, 1), 1) ? k = Error("Vc") : h && (k = Error("Wc"));
        if (k) {
            xy(k);
            var l = g.every(function(r) {
                return !r.T
            })
              , m = {}
              , p = (m.serviceworker_numNavigations = String(g.length),
            m.serviceworker_someRequestsMissingActionInfo = String(h),
            m.serviceworker_allRequestsMissingActionInfo = String(l),
            m.serviceworker_clientId = c,
            m);
            g.forEach(function(r, u) {
                p["serviceworker_sourceUrl" + u] = r.ga.url
            });
            vy(d.v, k, a, p)
        }
        YA(d.A, jf(H(e, uC, 1), 8), !!f);
        f = new HC;
        e = CC(new BC, e);
        I(f, BC, 4, e);
        return f
    })
}
;
function TC() {
    this.g = 5
}
y(TC, nC);
TC.prototype.j = function(a, c) {
    if (!c)
        return jh(Error("Xc"));
    a = new HC;
    var d = new DC;
    c = M(d, 1, c);
    I(a, DC, 6, c);
    return ih(a)
}
;
function UC(a) {
    this.g = 4;
    this.o = a
}
y(UC, nC);
UC.prototype.j = function(a) {
    var c = new HC;
    a = H(a, sC, 3);
    return ih(this.o.get(of(a, 1))).then(function(d) {
        d = d ? 1 : 2;
        var e = new EC;
        d = N(e, 1, d);
        I(c, EC, 5, d);
        return c
    })
}
;
function VC(a) {
    this.g = 8;
    this.o = a
}
y(VC, nC);
VC.prototype.j = function() {
    var a = T(this.o, "buildLabel")
      , c = new HC
      , d = new FC;
    a = M(d, 1, a);
    d = new GC;
    a = I(d, FC, 1, a);
    I(c, GC, 7, a);
    return ih(c)
}
;
function WC() {
    this.g = 2
}
y(WC, nC);
WC.prototype.j = function() {
    return ih(new HC)
}
;
function XC(a, c) {
    this.g = 6;
    this.v = a;
    this.o = c
}
y(XC, nC);
XC.prototype.j = function(a, c) {
    if (a = c ? oB(this.v, c) : null)
        a.J = !0;
    var d = this.o;
    c = UA(d, 100009, c);
    Zr(J(cs(es(Qy(c))), 4, !0), !!a);
    d.la(c);
    return ih(new HC)
}
;
function YC(a, c) {
    this.g = 9;
    this.v = a;
    this.o = c
}
y(YC, nC);
YC.prototype.j = function(a, c) {
    if (a = c ? oB(this.v, c) : null)
        a.O = !0,
        a.o.stop();
    var d = this.o;
    c = UA(d, 100010, c);
    Zr(J(cs(es(Qy(c))), 4, !0), !!a);
    d.la(c);
    return ih(new HC)
}
;
function ZC(a, c) {
    this.g = 0;
    this.v = a;
    this.o = c
}
y(ZC, nC);
ZC.prototype.j = function() {
    var a = this;
    return ih().then(function() {
        return fz(a.o, "cache_only_update")
    }).then(function() {
        return new HC
    }).Aa(function(c) {
        c = Ei(c);
        var d = {};
        ty(a.v, c, "messageHandler", (d.serviceworker_messageHandler_requestType = 0,
        d));
        return OC(c)
    })
}
;
function $C(a, c) {
    this.A = a;
    this.v = c;
    this.D = this.g = this.C = !1
}
$C.prototype.start = function() {
    var a = this;
    if (this.g)
        throw Error("Yc");
    this.g = !0;
    this.o = Date.now();
    this.A.clients.get(this.v).then(function() {
        a.C = !0
    }).catch(n());
    this.L = aD(this)
}
;
function bD(a) {
    if (!a.g)
        throw Error("Zc");
    return a.L
}
function $B(a) {
    if (!a.g)
        throw Error("$c");
    return Promise.resolve().then(function() {
        return a.C ? a.A.clients.get(a.v).then(function(c) {
            return !c
        }) : !1
    }).then(function(c) {
        c && !a.j ? a.j = Date.now() : c || (a.B = Date.now());
        return c
    })
}
$C.prototype.stop = function() {
    this.D = !0
}
;
function aD(a) {
    return Promise.resolve(lp(1E3)).then(function() {
        if (!(a.j || a.D || 3E4 < Date.now() - a.o))
            return $B(a).then(function() {
                return a.j ? void 0 : aD(a)
            })
    })
}
;function cD(a, c, d, e) {
    this.oa = a;
    this.D = null;
    this.M = this.B = !1;
    this.I = [];
    this.v = new uC;
    this.A = new wC;
    this.g = new vC;
    this.C = !1;
    this.F = d;
    this.L = e;
    this.o = new $C(c,e);
    this.P = !1;
    this.H = null;
    this.S = !1;
    this.fa = this.W = null;
    this.V = this.O = this.J = !1;
    J(this.v, 1, !1);
    J(this.v, 5, !1);
    this.j = []
}
cD.prototype.start = function() {
    if (this.C)
        throw Error("cd");
    this.C = !0;
    this.o.start();
    this.j.push(dD(this, 3E3));
    this.j.push(dD(this, 6E3));
    this.j.push(dD(this, 8E3));
    this.j.push(dD(this, 1E4));
    this.j.push(dD(this, 2E4));
    this.j.push(eD(this))
}
;
function XB(a) {
    if (!a.C)
        throw Error("dd");
    return Promise.all(a.j.concat([bD(a.o)])).then(n())
}
function WB(a, c) {
    a.P = !0;
    a.H = c
}
function dD(a, c) {
    return Promise.resolve(lp(c)).then(function() {
        return $B(a.o)
    }).then(function(d) {
        var e = a.F
          , f = UA(e, 100006, a.L);
        var g = new Vr;
        g = qf(g, 1, c);
        d = J(g, 2, d);
        g = cs(es(Qy(f)));
        I(g, Vr, 10, d);
        e.la(f)
    })
}
function eD(a) {
    return Promise.resolve(lp(26E3)).then(function() {
        var c = a.F
          , d = a.L;
        var e = a.o;
        if (!e.g)
            throw Error("ad");
        e = void 0 !== e.B ? e.B - e.o : null;
        var f = a.o;
        if (!f.g)
            throw Error("bd");
        var g = void 0 !== f.j ? f.j - f.o : null;
        var h = a.P;
        f = a.H;
        var k = a.S
          , l = a.W
          , m = a.fa
          , p = a.J
          , r = a.O
          , u = a.V
          , w = new Wr;
        h = J(w, 1, h);
        k = J(h, 2, k);
        p = J(k, 5, p);
        r = J(p, 6, r);
        u = J(r, 7, u);
        null != l && J(u, 3, l);
        null != m && qf(u, 4, m);
        null != e && qf(u, 8, e);
        null != g && qf(u, 9, g);
        d = UA(c, 100013, d);
        e = Yr(cs(es(Qy(d))), f);
        I(e, Wr, 14, u);
        c.la(d)
    })
}
;function fD(a, c) {
    oy(c, function(d) {
        var e = {}
          , f = oB(a, d.clientId);
        f && (e.serviceworker_isColdStart = String(f.D),
        f = f.oa.T,
        !d.g && f && (e.serviceworker_sourceActionPath = f.ya));
        return e
    })
}
function MC(a, c) {
    a.g || (a.g = 2 == c ? 3 : 4)
}
function gC(a) {
    a.g || (a.g = 5)
}
function PB(a, c) {
    if (c.g) {
        for (var d in a.j)
            3E5 <= Date.now() - a.j[d].creationTime && delete a.j[d];
        c.clientId && !a.j[c.clientId] && (a.j[c.clientId] = new gD(new cD(c,a.o,a.D,c.clientId)))
    }
    a.g || (a.g = 2,
    a.A = c.clientId)
}
function oB(a, c) {
    return c ? (a = a.j[c]) ? a.g : null : null
}
function SC(a, c) {
    var d = new xC
      , e = a.g;
    c && a.A == c && 2 == a.g && (e = 1);
    var f = oB(a, c);
    f && f.B ? (yC(d, sf(f.v)),
    zC(d, sf(f.A)),
    AC(d, sf(f.g))) : (f = new uC,
    J(f, 1, !0),
    yC(d, f),
    zC(d, new wC),
    AC(d, new vC));
    f = H(d, uC, 1);
    var g = H(d, wC, 2);
    M(f, 8, c);
    M(f, 6, a.B);
    N(f, 10, a.L);
    M(f, 9, a.F);
    N(f, 4, e);
    f.Lb(mf(f, 3) || !1);
    K(g, 1, a.C);
    K(g, 7, a.H);
    K(g, 2, a.v);
    return hD(a).then(function(h) {
        var k = H(d, uC, 1);
        J(k, 2, h);
        return d
    })
}
function hD(a) {
    return (a = a.o.registration.navigationPreload) ? ih(a.getState()).then(function(c) {
        return c.enabled
    }) : ih(!1)
}
function gD(a) {
    var c = Date.now();
    this.g = a;
    this.creationTime = c
}
;function SB(a, c, d, e) {
    c = iD(a, c, d, e);
    return Promise.resolve(wq(a.j, c))
}
function iD(a, c, d, e) {
    return jD(d, c).catch(function(f) {
        var g = {};
        g = (g.error_at_top_level_fetch_handling = "true",
        g);
        return Fz("none", Gi(f, g))
    }).then(function(f) {
        var g = f.ta;
        if (g) {
            var h = f.Wa;
            !h || h instanceof Kv && c.j || wy(a.g, c, f);
            return g
        }
        return kD(c, e).then(function(k) {
            wy(a.g, c, f, k);
            return k
        })
    })
}
function kD(a, c) {
    return Promise.resolve().then(function() {
        return a.g && c ? MB(c).then(function(d) {
            return d || Response.error()
        }) : Promise.resolve(Response.error())
    }).catch(function() {
        return Response.error()
    })
}
function KC(a, c, d) {
    d = d.Aa(function(e) {
        vy(a.g, Ei(e), c)
    });
    return Promise.resolve(wq(a.j, d))
}
function hB(a, c, d) {
    d = d.catch(function(e) {
        py(a.g, c, Ei(e))
    });
    return Promise.resolve(wq(a.j, d))
}
function kB(a, c) {
    return a.fetch(c).catch(function(d) {
        return Fz("none", Ei(d))
    })
}
function jD(a, c) {
    return a.then(function(d) {
        if (d.ta && d.ta.redirected && "follow" != c.ga.redirect)
            throw Error("ed");
        return d
    })
}
;function lD() {
    var a = eC
      , c = mD
      , d = new hC
      , e = new aC
      , f = nD
      , g = cC
      , h = dC;
    this.g = bC;
    this.j = a;
    this.A = c;
    this.F = d;
    this.v = e;
    this.H = f;
    this.o = h;
    fD(this.o, g);
    this.j.addEventListener("install", vq(this.g, this.D, this), !1);
    this.j.addEventListener("fetch", vq(this.g, this.B, this), !1);
    this.j.addEventListener("activate", vq(this.g, this.C, this), !1);
    this.j.addEventListener("message", vq(this.g, this.L, this), !1)
}
lD.prototype.D = function(a) {
    mC(this.F, a)
}
;
lD.prototype.C = function(a) {
    fC(this.v, a)
}
;
lD.prototype.L = function(a) {
    JC(this.H, a)
}
;
lD.prototype.B = function(a) {
    a.preloadResponse && a.preloadResponse.catch(n());
    NB(this.A, a)
}
;
function oD(a) {
    this.C = a.td || null;
    this.A = a.ee || !1;
    this.g = void 0
}
Ka(oD, Lp);
oD.prototype.j = function() {
    var a = new pD(this.C,this.A);
    this.g && (a.A = this.g);
    return a
}
;
oD.prototype.v = function(a) {
    return function() {
        return a
    }
}({});
function pD(a, c) {
    Y.call(this);
    this.M = a;
    this.D = c;
    this.A = void 0;
    this.status = this.readyState = 0;
    this.responseType = this.responseText = this.response = this.statusText = "";
    this.onreadystatechange = null;
    this.F = new Headers;
    this.o = null;
    this.I = "GET";
    this.J = "";
    this.g = !1;
    this.H = this.v = this.B = null
}
Ka(pD, Y);
v = pD.prototype;
v.open = function(a, c) {
    if (0 != this.readyState)
        throw this.abort(),
        Error("fd");
    this.I = a;
    this.J = c;
    this.readyState = 1;
    qD(this)
}
;
v.send = function(a) {
    if (1 != this.readyState)
        throw this.abort(),
        Error("gd");
    this.g = !0;
    var c = {
        headers: this.F,
        method: this.I,
        credentials: this.A,
        cache: void 0
    };
    a && (c.body = a);
    (this.M || z).fetch(new Request(this.J,c)).then(this.gd.bind(this), this.Gb.bind(this))
}
;
v.abort = function() {
    this.response = this.responseText = "";
    this.F = new Headers;
    this.status = 0;
    this.v && this.v.cancel("Request was aborted.").catch(aa(null));
    1 <= this.readyState && this.g && 4 != this.readyState && (this.g = !1,
    rD(this));
    this.readyState = 0
}
;
v.gd = function(a) {
    if (this.g && (this.B = a,
    this.o || (this.status = this.B.status,
    this.statusText = this.B.statusText,
    this.o = a.headers,
    this.readyState = 2,
    qD(this)),
    this.g && (this.readyState = 3,
    qD(this),
    this.g)))
        if ("arraybuffer" === this.responseType)
            a.arrayBuffer().then(this.ed.bind(this), this.Gb.bind(this));
        else if ("undefined" !== typeof z.ReadableStream && "body"in a) {
            this.v = a.body.getReader();
            if (this.D) {
                if (this.responseType)
                    throw Error("hd");
                this.response = []
            } else
                this.response = this.responseText = "",
                this.H = new TextDecoder;
            sD(this)
        } else
            a.text().then(this.fd.bind(this), this.Gb.bind(this))
}
;
function sD(a) {
    a.v.read().then(a.ad.bind(a)).catch(a.Gb.bind(a))
}
v.ad = function(a) {
    if (this.g) {
        if (this.D && a.value)
            this.response.push(a.value);
        else if (!this.D) {
            var c = a.value ? a.value : new Uint8Array(0);
            if (c = this.H.decode(c, {
                stream: !a.done
            }))
                this.response = this.responseText += c
        }
        a.done ? rD(this) : qD(this);
        3 == this.readyState && sD(this)
    }
}
;
v.fd = function(a) {
    this.g && (this.response = this.responseText = a,
    rD(this))
}
;
v.ed = function(a) {
    this.g && (this.response = a,
    rD(this))
}
;
v.Gb = function() {
    this.g && rD(this)
}
;
function rD(a) {
    a.readyState = 4;
    a.B = null;
    a.v = null;
    a.H = null;
    qD(a)
}
v.setRequestHeader = function(a, c) {
    this.F.append(a, c)
}
;
v.getResponseHeader = function(a) {
    return this.o ? this.o.get(a.toLowerCase()) || "" : ""
}
;
v.getAllResponseHeaders = function() {
    if (!this.o)
        return "";
    for (var a = [], c = this.o.entries(), d = c.next(); !d.done; )
        d = d.value,
        a.push(d[0] + ": " + d[1]),
        d = c.next();
    return a.join("\r\n")
}
;
function qD(a) {
    a.onreadystatechange && a.onreadystatechange.call(a)
}
Object.defineProperty(pD.prototype, "withCredentials", {
    get: function() {
        return "include" === this.A
    },
    set: function(a) {
        this.A = a ? "include" : "same-origin"
    }
});
var eC = self
  , tD = new oD({
    td: eC
});
tD.g = "same-origin";
Np = tD;
var uD = T(Bj(), "docs-sw-cache-prefix");
if (!uD)
    throw Error("id");
var wz = "/" + uD
  , Rq = uD + "-sw"
  , vD = eC
  , Qq = Bj()
  , wD = S(Qq, "docs-sw-ehnur")
  , xD = !0;
xD = void 0 === xD ? !1 : xD;
wD = void 0 === wD ? !1 : wD;
var yD = new lq;
yD.A = !1;
yD.v = !0;
yD.g = new Pq;
yD.j = xD;
yD.o = wD;
yD.Ba = Qq;
var zD = new kq(yD)
  , AD = T(Qq, "buildLabel");
mc(AD) || (zD.o.buildLabel = AD,
zD.o["build-label"] = AD);
zD.o.locale = "en";
zD.o.serviceworker_type = "editorSW";
vD.registration && (zD.o.serviceworker_activeAtStart = vD.registration.active ? "true" : "false",
vD.registration.scope && (zD.o.serviceworker_scope = vD.registration.scope));
var bC = zD
  , BD = new zj
  , yB = function(a) {
    a = Uw(a);
    return Array.from(a.values()).find(function(c) {
        var d = z.location.href
          , e = c.Ya + "/";
        return !!(c.Ya && 0 <= d.indexOf(e) && c.getType())
    }) || null
}(Bj())
  , cC = new function() {
    this.g = bC;
    this.j = []
}
  , fB = new function() {
    this.g = cC;
    this.j = this.g.g
}
  , uz = new Tu(bC,null,Bj(),BD,Nj(),void 0,void 0,!0)
  , vz = yB.getType()
  , CD = new Az
  , DD = fj();
bC.o.sid = DD;
var ED, jr = bC, os = uz, FD = vz, GD = wz, fr = Bj(), ms = function(a) {
    switch (a) {
    case "kix":
        return "kix";
    case "drawing":
        return "drawing";
    case "punch":
        return "punch";
    case "ritz":
        return "ritz";
    default:
        throw Error("kb`" + a);
    }
}(FD), HD = function(a) {
    switch (a) {
    case "kix":
        return 102;
    case "punch":
        return 103;
    case "ritz":
        return 105;
    case "drawing":
        return 104;
    default:
        throw Error("Kc");
    }
}(FD), tr = new sv(new (n()),fr,void 0,jr);
tr.v.o = GD;
var Cr = new sr;
S(fr, "docs-esi") || S(fr, "docs-dli") ? Cr = new er : S(fr, "docs-ecci") && (Cr = new Br);
var gs = Cr
  , ns = fr;
if (S(ns, "docs-eil")) {
    var ID;
    ID = new Dr;
    var JD = new SA;
    JD.v = ID;
    JD.o = new oA;
    JD.j = !0;
    M(JD.g.g, 1, DD);
    var KD = JD.g;
    kf(KD.g, 6);
    N(KD.g, 6, HD);
    var LD;
    mA(JD.g);
    var MD, PA, ND = new RA;
    ND.j = JD.g;
    PA = ND;
    null == PA.g && (PA.g = new aA);
    PA.g.g[uA.R()] = new QA;
    PA.g.g[qA.R()] = new KA;
    var OD = PA.g, PD, QD = PA.j;
    if (!Ve(kA(QD), gA, 1)) {
        var RD = kA(QD)
          , SD = new gA;
        I(RD, gA, 1, SD)
    }
    PD = H(kA(QD), gA, 1);
    OD.j = PD;
    for (var TD = vg(OD.o), UD = 0; UD < TD.length; UD++)
        TD[UD].g(OD.j);
    MD = new OA;
    LD = new CA(MD,new IA(MD,JD.v,JD.o,JD.j,null),!1);
    var VD = LD.Pb()
      , WD = T(ns, "buildLabel");
    if (null == VD.v) {
        VD.v = new hA;
        var XD = kA(VD);
        I(XD, hA, 2, VD.v)
    }
    M(VD.v, 1, WD);
    var YD = $A(T(ns, "jobset"))
      , ZD = kA(VD);
    kf(ZD, 4);
    var $D = kA(VD);
    N($D, 4, YD);
    var aE = Ec();
    lA(VD);
    var bE = lA(VD);
    M(bE, 2, aE);
    lA(VD);
    var cE = lA(VD);
    M(cE, 1, "en");
    var dE = 1E3 * Date.now();
    gf(VD.g, 2);
    K(VD.g, 2, dE);
    var eE, fE = new fA, gE = !!T(ns, "docs-offline-lsuid");
    eE = J(fE, 1, gE);
    var hE = H(kA(VD), gA, 1);
    Ve(hE, fA, 20);
    var iE = H(kA(VD), gA, 1);
    I(iE, fA, 20, eE);
    var jE;
    var kE = Bj()
      , lE = kE.get("ilcm");
    if (null == lE)
        jE = null;
    else {
        var qr = lE.je
          , mE = Bj();
        null != mE.get("ilcm") && S(mE, "icso") && fj();
        var pr = lE.ei;
        kE.get("buildLabel");
        jE = new or
    }
    var nE = jE;
    if (nE) {
        var oE, pE = new Rr;
        oE = cf(pE, 1, nE.j, re);
        var qE = LD.Pb()
          , rE = lA(qE);
        Ve(rE, Rr, 10);
        var sE = lA(qE);
        I(sE, Rr, 10, oE)
    }
    LD.mc();
    ED = LD
} else
    ED = new nA;
var jC = ED
  , iC = new cz(eC,CD,uD,bC,uz,cC,jC,Bj());
iC.start();
var dC = new function() {
    var a = eC
      , c = jC
      , d = Bj();
    this.o = a;
    this.B = T(d, "buildLabel");
    this.L = $A(T(d, "jobset"));
    this.F = DD;
    this.D = c;
    this.j = {};
    this.C = null;
    this.H = z._docs_swStartLoad || null;
    this.A = this.g = this.v = null
}
  , nD = new function() {
    var a = dC;
    this.j = cC;
    this.o = fB;
    this.v = a;
    this.g = {}
}
  , tE = new ZC(cC,iC);
IC(IC(IC(IC(IC(IC(IC(IC(IC(IC(nD, tE), new QC(iC)), new PC(cC,iC,tE)), new WC), new XC(dC,jC)), new YC(dC,jC)), new RC(cC,dC,jC)), new UC(eC.clients)), new TC), new VC(Bj()));
var mD = new function() {
    var a = eC
      , c = bC
      , d = cC
      , e = iC
      , f = uz
      , g = dC
      , h = jC
      , k = Bj();
    this.v = yB;
    this.H = new LB(f,e,k);
    c = new xB(f,e,c,k);
    var l = new Mz(e);
    this.j = new IB(a,d,k);
    f = new eB(h,f);
    this.B = new HB(l,this.j,!0,f);
    this.F = new FB(l,this.j,f,Fj(k, "docs-sw-nfhms"));
    this.S = new HB(this.j,c,!1,f);
    this.P = new HB(c,this.j,!0,f);
    this.M = new jB(this.j,c,d,h,f,g);
    this.C = fB;
    this.A = d;
    this.D = e;
    this.g = g;
    this.L = a;
    this.o = h;
    this.O = new vB(d,this.v);
    this.J = S(k, "docs-efcs");
    this.I = S(k, "docs-doie")
}
  , kC = wi(window.location.href, "zx")
  , lC = !(eC.registration.active && eC.registration.active.scriptURL == window.location.href);
new lD;
var uE = dC
  , vE = Date.now();
uE.C = vE - z.performance.now();
uE.v = vE;
function _ModuleManager_initialize() {}
;// Google Inc.

//# sourceMappingURL=editor_sw_bin_editor_main.sourcemap
