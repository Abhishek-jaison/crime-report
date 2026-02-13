
import React from 'react';

interface TopHeaderProps {
  title: string;
}

const TopHeader: React.FC<TopHeaderProps> = ({ title }) => {
  return (
    <header className="h-20 bg-white/80 dark:bg-slate-900/80 backdrop-blur-md border-b border-slate-200 dark:border-slate-800 sticky top-0 z-10 flex items-center justify-between px-8">
      <div className="flex items-center gap-4">
        <h2 className="text-2xl font-bold text-slate-800 dark:text-white lg:hidden">
            {title}
        </h2>
        <div className="relative w-64 md:w-96">
            <span className="material-icons absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">search</span>
            <input 
                className="w-full pl-10 pr-4 py-2.5 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg text-sm focus:ring-2 focus:ring-primary focus:border-transparent transition-all" 
                placeholder="Search case, location, or user..." 
                type="text"
            />
        </div>
      </div>

      <div className="flex items-center gap-4">
        <button className="w-10 h-10 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 flex items-center justify-center text-slate-600 dark:text-slate-400 relative">
          <span className="material-icons text-xl">notifications</span>
          <span className="absolute top-2.5 right-2.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white dark:border-slate-900"></span>
        </button>
        <button className="w-10 h-10 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 flex items-center justify-center text-slate-600 dark:text-slate-400">
          <span className="material-icons text-xl">dark_mode</span>
        </button>
        <div className="h-6 w-px bg-slate-200 dark:border-slate-800 mx-2 hidden md:block"></div>
        <button className="bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg text-sm font-semibold flex items-center gap-2 transition-colors shadow-sm shadow-primary/20">
          <span className="material-icons text-lg">add</span>
          <span className="hidden sm:inline">New Report</span>
        </button>
      </div>
    </header>
  );
};

export default TopHeader;
