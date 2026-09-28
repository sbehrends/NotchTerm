import Nav from "@/components/Nav";
import Hero from "@/components/Hero";
import Features from "@/components/Features";
import FinalCTA from "@/components/FinalCTA";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Nav />
      <main id="main">
        <Hero />

        {/* Dark section — the "carbon" half of Cream & Carbon. */}
        <div className="bg-black text-white">
          <Features />
          <FinalCTA />
          <Footer />
        </div>
      </main>
    </>
  );
}
