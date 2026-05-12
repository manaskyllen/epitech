import MannequinViews from "./components/MannequinViews";
import ClothesTop from "./components/clothes/ClothesTop";
import ClothesBottom from "./components/clothes/ClothesBottom";
import ClothesShoes from "./components/clothes/ClothesShoes";
import { useEffect } from "react";
import { attachWebviewReceiver } from "./clothing/clothingService";

function App() {
  useEffect(() => {
    try {
      attachWebviewReceiver();
    } catch {
      // ignore
    }
  }, []);

  return (
    <div className="bg-[#FDFDFD] text-[#424242]">
      <div className="flex w-full flex-col gap-6">

        {/* Mannequin */}
        <section className="h-[500px] w-full bg-[#FDFDFD]">
          <div className="h-full w-full">
            <MannequinViews />
          </div>
        </section>

        {/* Sélecteurs de vêtements */}
        <section className="space-y-5 pb-6">

          {/* Haut */}
          <article className="rounded-2xl bg-[#FDFDFD]">
            <div className="mb-1">
              <h2 className="text-sm font-semibold">Haut</h2>
            </div>
            <ClothesTop />
          </article>

          {/* Bas */}
          <article className="rounded-2xl bg-[#FDFDFD]">
            <div className="mb-1">
              <h2 className="text-sm font-semibold">Pantalon</h2>
            </div>
            <ClothesBottom />
          </article>

          {/* Chaussures */}
          <article className="rounded-2xl bg-[#FDFDFD]">
            <div className="mb-1">
              <h2 className="text-sm font-semibold">Chaussures</h2>
            </div>
            <ClothesShoes />
          </article>
        </section>
      </div>
    </div>
  );
}

export default App;
