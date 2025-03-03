/-
Copyright (c) 2025 Yaël Dillies, Michał Mrugała. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Michał Mrugała
-/

import Mathlib
import Toric.Mathlib.CategoryTheory.Monoidal.Category


open CategoryTheory Mon_Class MonoidalCategory ChosenFiniteProducts

section
variable {C : Type*} [Category C] [MonoidalCategory C] [BraidedCategory C]

class CommMon_Class (X : C) [Mon_Class X] where
  mul_comm' : (β_ X X).hom ≫ mul = mul := by aesop_cat

namespace CommMon_Class

@[reassoc (attr := simp)]
theorem mul_comm (X : C) [Mon_Class X] [CommMon_Class X] : (β_ X X).hom ≫ μ = μ := mul_comm'

end CommMon_Class

end


namespace Mon_

variable {C : Type*} [Category C] [ChosenFiniteProducts C] {M N : Mon_ C}  [CommMon_Class N.X]

lemma gigaDiagram :
    (α_ _ _ _).hom
    ≫ M.X ◁ (α_ _ _ _).inv
    ≫ M.X ◁ (M.mul ▷ M.X)
    ≫ M.X ◁ M.mul
    ≫ M.mul
      = (M.mul ⊗ M.mul)
        ≫ M.mul := calc
  _ = (α_ _ _ _).hom
        ≫ M.X ◁ ((α_ _ _ _).inv ≫ M.mul ▷ M.X ≫ M.mul)
        ≫ M.mul := by simp [-Mon_.mul_assoc]
  _ = (α_ _ _ _).hom
        ≫ M.X ◁ M.X ◁ M.mul
        ≫ M.X ◁ M.mul
        ≫ M.mul := by
    simp [M.mul_assoc]
  _ = (M.X ⊗ M.X) ◁ M.mul
        ≫ (α_ _ _ _).hom
        ≫ M.X ◁ M.mul
        ≫ M.mul := by simp
  _ = (M.X ⊗ M.X) ◁ M.mul
        ≫ M.mul ▷ M.X
        ≫ M.mul := by simp
  _ = (M.mul ⊗ M.mul) ≫ M.mul := by
    rw [tensorHom_def']
    simp

@[simps]
instance Hom.instMul : Mul (M ⟶ N) where
  mul f g := {
    hom := lift f.hom g.hom ≫ N.mul
    one_hom := by
      rw [← Category.assoc]
      simp
      have : lift N.one N.one = lift (𝟙 (𝟙_ C)) (𝟙 (𝟙_ C)) ≫ (N.one ⊗ N.one) := by simp
      rw [this]
      rw [Category.assoc]
      simp
    mul_hom := by
      apply yoneda.map_injective
      ext
      simp
      sorry
    /-
      rw [← Category.assoc G.mul]
      simp
      let e := calc
        (H.X ⊗ H.X) ⊗ (H.X ⊗ H.X)
        _ ≅ H.X ⊗ (H.X ⊗ (H.X ⊗ H.X)) := α_ _ _ _
        _ ≅ H.X ⊗ ((H.X ⊗ H.X) ⊗ H.X) := H.X ◁ (α_ _ _ _).symm
        _ ≅ H.X ⊗ ((H.X ⊗ H.X) ⊗ H.X) := H.X ◁ β_ H.X H.X ▷ H.X
        _ ≅ H.X ⊗ (H.X ⊗ (H.X ⊗ H.X)) := H.X ◁ α_ _ _ _
        _ ≅ (H.X ⊗ H.X) ⊗ (H.X ⊗ H.X) := (α_ _ _ _).symm
      calc lift ((f.hom ⊗ f.hom) ≫ H.mul) ((g.hom ⊗ g.hom) ≫ H.mul) ≫ H.mul
      _ = (lift f.hom f.hom ⊗ lift g.hom g.hom) ≫ e.inv ≫ (tensorHom H.mul H.mul) ≫ H.mul := sorry
      _ = ((lift f.hom g.hom ⊗ lift f.hom g.hom) ≫ e.hom) ≫ e.inv ≫ (tensorHom H.mul H.mul) ≫ H.mul := by
        congr!
        sorry
      _ = e.hom ≫ e.inv ≫ (lift f.hom g.hom ⊗ lift f.hom g.hom) ≫ (tensorHom H.mul H.mul) ≫ H.mul := by simp
      _ = (lift f.hom g.hom ⊗ lift f.hom g.hom) ≫ (tensorHom H.mul H.mul) ≫ H.mul := by simp
    -/
  }

end  Mon_

#exit

namespace Grp_

section

open ChosenFiniteProducts MonoidalCategory

variable {C : Type*} [Category C] [ChosenFiniteProducts C] {G H : Mon_ C} [CommMon_Class H.X]



instance instCommGroup_HomToComm (G H : Grp_ C) [CommMon_Class H.X] : CommGroup (G ⟶ H) where
  mul_assoc f g h := sorry
  one := sorry
  one_mul := sorry
  mul_one := sorry
  inv := sorry
  inv_mul_cancel := sorry
  mul_comm := sorry

end
