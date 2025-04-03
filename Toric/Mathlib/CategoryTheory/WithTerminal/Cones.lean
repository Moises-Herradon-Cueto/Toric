import Mathlib.CategoryTheory.Comma.Over.Basic
import Mathlib.CategoryTheory.FinCategory.Basic
import Mathlib.CategoryTheory.Limits.Shapes.Terminal
import Mathlib.CategoryTheory.Limits.Shapes.IsTerminal
import Mathlib.Data.Fintype.Basic
import Mathlib.Data.Fintype.Option
import Mathlib.CategoryTheory.WithTerminal

/-!
# Relations between `Cone`, `WithTerminal` and `Over`

Given a categories `C` and `J`, an object `X : C` and a functor `K : J ⥤ Over X`,
it has an obvious lift `liftFromOver K : WithFinal J ⥤ C`. These two functors have
equivalent categories of cones (`coneEquiv`). As a corollary, the limit of `K` "is" the
limit of `liftFromOver K`, and viceversa
-/

open CategoryTheory CategoryTheory.Limits CategoryTheory.WithTerminal -- CategoryTheory.con

universe w w' v₁ v₂ u₁ u₂
variable {C : Type u₁} [Category.{v₁} C]
variable {D : Type u₂} [Category.{v₂} D]
variable {J : Type w} [Category.{w'} J]

namespace CategoryTheory.Limits.WithTerminal

  -- These should go somewhere else, but I'm not sure where
  def OptionEquiv   : (Option J) ≃ (WithTerminal J) where
  toFun
  | some a => of a
  | none => star
  invFun
  | of a => some a
  | star => none
  left_inv
  | some _
  | none => by simp
  right_inv
  | of _
  | star => by simp

  instance IsFinType [Fintype J] : Fintype (WithTerminal J) :=
    Fintype.ofEquiv (Option J) OptionEquiv

  instance IsSmall  [SmallCategory J] :
  SmallCategory (WithTerminal J) := inferInstance

  instance IsFin  [SmallCategory J] [FinCategory J] :
  FinCategory (WithTerminal J) := {
    fintypeObj := inferInstance
    fintypeHom a b := match a, b with
    | star, star => (inferInstance : Fintype PUnit)
    | of _, star => (inferInstance : Fintype PUnit)
    | star, of _ => (inferInstance : Fintype PEmpty)
    | of a, of b => (inferInstance : Fintype (a ⟶ b))
  }

  @[simps]
  def asNatTransf {X : C} (K : J ⥤ Over X) :
  NatTrans (K ⋙ Over.forget X) ((Functor.const J).obj X) where
    app a := (K.obj a).hom

  /-- For any functor `K : J ⥤ Over X`, there is a canonical extension
  `WithTerminal J ⥤ C`, that sends `star` to `X`-/
  @[simps!]
  def liftFromOver {X : C} (K : J ⥤ Over X) : WithTerminal J ⥤ C :=
    ofCommaObject {
      left := K ⋙ Over.forget X
      right := X
      hom := asNatTransf K
    }

  /-- The extension of a functor to over categories behaves well with compositions -/
  @[simps]
  def extendCompose {X : C} (K : J ⥤ Over X) (F : C ⥤ D) :
   (liftFromOver K ⋙ F) ≅ liftFromOver (K ⋙ (Over.post F)) where
    hom := {
      app
      | star => 𝟙 _
      | of a => 𝟙 _
    }
    inv := {
      app
      | star => 𝟙 _
      | of a => 𝟙 _
    }

  @[simps]
  def coneLift {X : C} {K : J ⥤ Over X} : Cone K ⥤ Cone (liftFromOver K) where
  obj t := {
    pt := t.pt.left
    π := {
      app a := match a with
      | of a => CommaMorphism.left (t.π.app a)
      | star => t.pt.hom
      naturality a b f:=
      match a, b with
      | star , star
      | of a, star => by aesop
      | star, of _ => by contradiction
      | of a, of b => by
        have : (t.π.app b).left = (t.π.app a).left ≫ (K.map f).left := by
          calc
            (t.π.app b).left = (t.π.app a ≫ K.map f).left := by
              simp only [Functor.const_obj_obj, Cone.w]
            _ = (t.π.app a).left ≫ (K.map f).left := rfl
        simpa [Functor.const_obj_obj, Cone.w]
    }
  }
  map {t₁ t₂} f := {
    hom := f.hom.left
    w := by
      intro a
      cases a with
      | star => aesop_cat
      | of a =>
          have := by calc
            f.hom.left ≫ (t₂.π.app a).left =  (f.hom ≫ t₂.π.app a).left := by rfl_cat
            _ = (t₁.π.app a).left := by simp_all only [ConeMorphism.w, Functor.const_obj_obj]
          simpa
  }

  @[simps]
  def coneBack {X : C} {K : J ⥤ Over X} : Cone (liftFromOver K) ⥤ Cone K where
  obj t := {
    pt := Over.mk (t.π.app star)
    π := {
        app a := {
            left := t.π.app (of a)
            right := 𝟙 _
            w := by
              have := by
                calc
                  t.π.app (of a) ≫ (K.obj a).hom = t.π.app (of a)  ≫
                    (liftFromOver K).map (homFrom a) := rfl
                  _ = t.π.app star := by simp only [Functor.const_obj_obj, Cone.w]
              simp [this]
        }
        naturality a b f := by
          ext
          let f₂ := incl.map f
          have eq_after_K: (K.map f₂).left = (K.map f).left := by aesop
          have nat : t.π.app (of b) =
            t.π.app (of a) ≫ (K.map f₂).left := by simpa using t.π.naturality f₂
          simp [nat, eq_after_K]
    }
  }
  map {t₁ t₂ f} := {
    hom := Over.homMk f.hom (by aesop_cat)
  }

  @[simp]
  def coneToFromObj {X : C} {K : J ⥤ Over X} (t : Cone K) :
   (coneBack.obj (coneLift.obj t)).pt = t.pt := by aesop

  @[simps]
  def coneLiftBack {X : C} {K : J ⥤ Over X} (t : Cone K) : coneBack.obj (coneLift.obj t) ≅ t where
    hom := {
      hom := 𝟙 t.pt
    }
    inv := {
      hom := 𝟙 t.pt
    }

  @[simps]
  def coneBackLift {X : C} {K : J ⥤ Over X} (t : Cone (liftFromOver K)) :
  coneLift.obj (coneBack.obj t) ≅ t where
    hom := {
      hom := 𝟙 t.pt
    }
    inv := {
      hom := 𝟙 t.pt
    }

  def coneEquiv {X : C} (K : J ⥤ Over X) : Cone K ≌ Cone (liftFromOver K) where
    functor := coneLift
    inverse := coneBack
    unitIso := NatIso.ofComponents coneLiftBack
    counitIso := NatIso.ofComponents coneBackLift

  def limitEquiv {X : C} {K : J ⥤ Over X} {t : Cone K} :
   IsLimit (coneLift.obj t) ≃ IsLimit t := IsLimit.ofConeEquiv (coneEquiv K)

end CategoryTheory.Limits.WithTerminal
