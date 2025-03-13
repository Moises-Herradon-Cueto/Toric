/-
Copyright (c) 2025 Yaël Dillies, Michał Mrugała. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Michał Mrugała
-/
import Mathlib.Algebra.Category.Grp.ChosenFiniteProducts
import Mathlib.CategoryTheory.Monoidal.FunctorCategory
import Toric.Mathlib.CategoryTheory.Monoidal.Grp_

open CategoryTheory MonoidalCategory  Limits ChosenFiniteProducts Mon_Class

namespace CategoryTheory

universe u v v₁ v₂ u₁ u₂

variable {C : Type u₁} [Category.{v₁} C] [ChosenFiniteProducts C]

@[simps]
def homToProd {X Y Z : C} : (Z ⟶ X ⊗ Y) ≃ (Z ⟶ X) × (Z ⟶ Y) where
  toFun f := ⟨f ≫ fst _ _, f ≫ snd _ _⟩
  invFun f := lift f.1 f.2
  left_inv _ := by simp
  right_inv _ := by simp

namespace Functor
variable {D E : Type*} [Category D] [Category E] [ChosenFiniteProducts E]

noncomputable def tensorObjComp (F G : D ⥤ C) (H : C ⥤ E) [PreservesFiniteProducts H] :
    (F ⊗ G) ⋙ H ≅ (F ⋙ H) ⊗ (G ⋙ H) :=
  NatIso.ofComponents (fun X ↦ prodComparisonIso H (F.obj X) (G.obj X)) fun {X Y} f ↦ by
    dsimp
    ext
    · simp
      sorry
    · simp
      sorry

protected def RepresentableBy.tensorObj {F : Cᵒᵖ ⥤ Type v} {G : Cᵒᵖ ⥤ Type v} {X Y : C}
    (h₁ : F.RepresentableBy X) (h₂ : G.RepresentableBy Y) : (F ⊗ G).RepresentableBy (X ⊗ Y) where
  homEquiv {Z} := homToProd.trans (Equiv.prodCongr h₁.homEquiv h₂.homEquiv)
  homEquiv_comp {Z W} f g := by
    refine Prod.ext ?_ ?_
    · refine (h₁.homEquiv_comp _ _).trans ?_
      simp
      change
        F.map f.op (F.map g.op (h₁.homEquiv (fst X Y))) = F.map f.op (h₁.homEquiv (g ≫ fst X Y))
      simp [h₁.homEquiv_comp]
    · refine (h₂.homEquiv_comp _ _).trans ?_
      simp
      change
        G.map f.op (G.map g.op (h₂.homEquiv (snd X Y))) = G.map f.op (h₂.homEquiv (g ≫ snd X Y))
      simp [h₂.homEquiv_comp]

end CategoryTheory.Functor

section

variable {C : Type*} [Category C] [ChosenFiniteProducts C]
    {X Y : C} [Grp_Class X] [Grp_Class Y]

@[simps]
instance : Grp_Class <| 𝟙_ C where
  one := 𝟙 _
  mul := toUnit _
  inv := 𝟙 _

noncomputable instance : Grp_Class <| X ⊗ Y :=
  .ofRepresentableBy _ (yonedaGrpObj X ⊗ yonedaGrpObj Y) <| by
    refine .ofIso ((yonedaGrpObjRepresentableBy _).tensorObj (yonedaGrpObjRepresentableBy _))
      (Functor.tensorObjComp _ _ _).symm

noncomputable instance : ChosenFiniteProducts <| Grp_ C where
  product X Y := {
    cone.pt := .mk' (X.X ⊗ Y.X)
    cone.π := sorry
    isLimit.lift s := {
      hom := by
        dsimp
        sorry
      one_hom := sorry
      mul_hom := sorry
    }
    isLimit.fac := sorry
    isLimit.uniq := sorry
  }
  terminal.cone.pt := Grp_.mk' (𝟙_ C)
  terminal.cone.π.app := isEmptyElim
  terminal.cone.π.naturality := isEmptyElim
  terminal.isLimit.lift s := {
    hom := toUnit _
    one_hom := toUnit_unique _ _
    mul_hom := toUnit_unique _ _
  }
  terminal.isLimit.uniq s m h := by ext; exact toUnit_unique _ _

end
