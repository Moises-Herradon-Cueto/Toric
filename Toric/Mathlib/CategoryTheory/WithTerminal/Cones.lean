import Mathlib.CategoryTheory.Comma.Over.Basic
import Toric.Mathlib.CategoryTheory.WithTerminal

/-!
# Relations between `Cone`, `WithTerminal` and `Over`

Given a categories `C` and `J`, an object `X : C` and a functor `K : J ⥤ Over X`,
it has an obvious lift `liftFromOver K : WithFinal J ⥤ C`. These two functors have
equivalent categories of cones (`coneEquiv`). As a corollary, the limit of `K` "is" the
limit of `liftFromOver K`, and viceversa
-/

open CategoryTheory CategoryTheory.Limits CategoryTheory.WithTerminal

universe w w' v₁ v₂ u₁ u₂
variable {C : Type u₁} [Category.{v₁} C]
variable {D : Type u₂} [Category.{v₂} D]
variable {J : Type w} [Category.{w'} J]

namespace CategoryTheory.Limits.WithTerminal

@[simps]
def asNatTransf {X : C} (K : J ⥤ Over X) :
NatTrans (K ⋙ Over.forget X) ((Functor.const J).obj X) where
  app a := (K.obj a).hom

@[simps]
def commaFromFunctorToOver {X : C} : (J ⥤ Over X) ⥤ Comma (𝟭 (J ⥤ C)) (Functor.const J) where
  obj K := {
    left := K ⋙ Over.forget X
    right := X
    hom.app a := (K.obj a).hom
  }
  map f := {
    left := whiskerRight f (Over.forget X)
    right := 𝟙 X
  }

/-- For any functor `K : J ⥤ Over X`, there is a canonical extension
`WithTerminal J ⥤ C`, that sends `star` to `X`-/
@[simps!]
def liftFromOver {X : C} : (J ⥤ Over X) ⥤ (WithTerminal J ⥤ C) :=
  commaFromFunctorToOver ⋙ equivComma.inverse

/-- The extension of a functor to over categories behaves well with compositions -/
@[simps]
def extendCompose {X : C} (K : J ⥤ Over X) (F : C ⥤ D) :
  (liftFromOver.obj K ⋙ F) ≅ liftFromOver.obj (K ⋙ (Over.post F)) where
hom.app
| star => 𝟙 _
| of a => 𝟙 _
inv.app
| star => 𝟙 _
| of a => 𝟙 _

@[simps]
def coneLift {X : C} {K : J ⥤ Over X} : Cone K ⥤ Cone (liftFromOver.obj K) where
obj t := {
  pt := t.pt.left
  π.app
  | of a => CommaMorphism.left (t.π.app a)
  | star => t.pt.hom
  π.naturality
  | star , star , _
  | of a, star, _ => by aesop
  | star, of _, _ => by contradiction
  | of a, of b , f => by
    have := by
      calc
        (t.π.app b).left = (t.π.app a ≫ K.map f).left := by
          simp only [Functor.const_obj_obj, Cone.w]
        _ = (t.π.app a).left ≫ (K.map f).left := rfl
    simpa
}
map {t₁ t₂} f := {
  hom := f.hom.left
  w
  | star => by aesop_cat
  | of a => by
    have := by calc
      f.hom.left ≫ (t₂.π.app a).left = (f.hom ≫ t₂.π.app a).left := by rfl_cat
      _ = (t₁.π.app a).left := by simp_all only [ConeMorphism.w, Functor.const_obj_obj]
    simpa
}

@[simps]
def coneBack {X : C} {K : J ⥤ Over X} : Cone (liftFromOver.obj K) ⥤ Cone K where
obj t := {
  pt := Over.mk (t.π.app star)
  π.app a := {
    left := t.π.app (of a)
    right := 𝟙 _
    w := by
      have := by
        calc
          t.π.app (of a) ≫ (K.obj a).hom = t.π.app (of a) ≫
            (liftFromOver.obj K).map (homFrom a) := rfl
          _ = t.π.app star := by simp only [Functor.const_obj_obj, Cone.w]
      simpa
  }
  π.naturality a b f := by
    ext
    let f₂ := incl.map f
    have eq_after_K: (K.map f₂).left = (K.map f).left := by aesop
    have nat : t.π.app (of b) =
      t.π.app (of a) ≫ (K.map f₂).left := by simpa using t.π.naturality f₂
    simp [nat, eq_after_K]
}
map {t₁ t₂ f} := {
  hom := Over.homMk f.hom
}

@[simp]
lemma coneToFromObj {X : C} {K : J ⥤ Over X} (t : Cone K) :
  (coneBack.obj (coneLift.obj t)).pt = t.pt := by aesop

@[simps]
def coneLiftBack {X : C} {K : J ⥤ Over X} (t : Cone K) : coneBack.obj (coneLift.obj t) ≅ t where
  hom.hom := 𝟙 t.pt
  inv.hom := 𝟙 t.pt

@[simps]
def coneBackLift {X : C} {K : J ⥤ Over X} (t : Cone (liftFromOver.obj K)) :
coneLift.obj (coneBack.obj t) ≅ t where
  hom.hom := 𝟙 t.pt
  inv.hom := 𝟙 t.pt

def coneEquiv {X : C} (K : J ⥤ Over X) : Cone K ≌ Cone (liftFromOver.obj K) where
  functor := coneLift
  inverse := coneBack
  unitIso := NatIso.ofComponents coneLiftBack
  counitIso := NatIso.ofComponents coneBackLift

def limitEquiv {X : C} {K : J ⥤ Over X} {t : Cone K} :
  IsLimit (coneLift.obj t) ≃ IsLimit t := IsLimit.ofConeEquiv (coneEquiv K)

end CategoryTheory.Limits.WithTerminal
