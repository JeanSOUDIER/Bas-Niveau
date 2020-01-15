#include <iostream>
#include <windows.h>
#include <cmath>
#include <cstdlib>

using namespace std;
void adVoisines();
void adImages();
void posJoueur();
void rassemblementImages();
void hexaPourMemoire();

int tabDepart[20][20] = {{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},{1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1},{1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,0,1,1},{1,0,0,1,0,0,0,1,0,1,0,1,0,0,0,0,1,0,0,1},{1,1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,1,1,0,1},{1,0,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1},{1,0,1,1,0,1,0,1,0,1,0,1,1,1,0,1,0,1,1,1},{1,0,1,0,0,1,0,1,0,0,0,1,0,0,0,0,0,0,0,1},{1,0,1,0,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1},{1,0,1,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1},{1,0,1,1,0,1,1,1,1,1,0,1,0,1,0,1,0,0,0,1},{1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,1,1,1,0,1},{1,0,1,1,1,1,1,1,0,1,1,1,0,0,0,1,0,0,0,1},{1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1,0,1,1,1},{1,0,1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0,1},{1,0,1,0,1,1,0,1,1,1,0,1,0,1,1,1,1,1,0,1},{1,0,1,0,1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1},{1,0,1,0,1,1,1,1,1,1,1,1,0,1,0,1,1,1,0,1},{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1},{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}};
int tabMid[20][20];
int adressesVoisines[182][4];
int adressesVoisines2[182][4];
int adressesImages[182][4];
int positionsJoueur[182][2];
int adressesImagesMemoire[182][2];

int main()
{
    int indice = 0;
    for(int i=0; i<20; i++)
    {
        for(int j=0; j<20; j++)
        {
            if(tabDepart[i][j] == 0)
            {
                tabMid[i][j] = indice;
                if(indice < 100)
                {
                    cout << " ";
                }
                cout << " " << indice << " ";
                if(indice < 10)
                {
                    cout << " ";
                }
                indice++;
            }
            else
            {
                tabMid[i][j] = -1;
                cout << "#####";
            }
        }
        cout << endl;
    }
    adVoisines();
    adImages();
    posJoueur();
    rassemblementImages();
    hexaPourMemoire();
    return 0;
}

void adVoisines()
{
    for(int i=1; i<19; i++)
    {
        for(int j=1; j<19; j++)
        {
            if(tabDepart[i-1][j] == 1)
            {
                adressesVoisines[tabMid[i][j]][0] = tabMid[i][j];
            }
            else
            {
                adressesVoisines[tabMid[i][j]][0] = tabMid[i-1][j];
            }

            if(tabDepart[i+1][j] == 1)
            {
                adressesVoisines[tabMid[i][j]][2] = tabMid[i][j];
            }
            else
            {
                adressesVoisines[tabMid[i][j]][2] = tabMid[i+1][j];
            }

            if(tabDepart[i][j-1] == 1)
            {
                adressesVoisines[tabMid[i][j]][1] = tabMid[i][j];
            }
            else
            {
                adressesVoisines[tabMid[i][j]][1] = tabMid[i][j-1];
            }

            if(tabDepart[i][j+1] == 1)
            {
                adressesVoisines[tabMid[i][j]][3] = tabMid[i][j];
            }
            else
            {
                adressesVoisines[tabMid[i][j]][3] = tabMid[i][j+1];
            }
        }
    }
    /////////////// Vérification des codes stockés
    /*for(int i=0; i<182; i++)
    {
        cout << i << "   " << adressesVoisines[i][0] << "   " << adressesVoisines[i][1] << "   " << adressesVoisines[i][2] << "   " << adressesVoisines[i][3] <<endl;
    }*/
    //cout << adressesVoisines[181][0] << "   " << adressesVoisines[181][1] << "   " << adressesVoisines[181][2] << "   " << adressesVoisines[181][3] <<endl;

}

void adImages()
{
    for(int i=1; i<19; i++)
    {
        for(int j=1; j<19; j++)
        {
            if(tabDepart[i-1][j] == 1) //On regarde au Nord
            {
                adressesImages[tabMid[i][j]][0] = 8; //Très proche
            }
            else
            {
                if(i>1)
                {

                    if(tabDepart[i-2][j] == 0) //Loin
                    {
                        if(tabDepart[i-1][j-1] == 0 && tabDepart[i-1][j+1] == 1) //Gauche
                        {
                            adressesImages[tabMid[i][j]][0] = 5;
                        }
                        else if(tabDepart[i-1][j-1] == 1 && tabDepart[i-1][j+1] == 0) //Droite
                        {
                            adressesImages[tabMid[i][j]][0] = 3;
                        }
                        else if(tabDepart[i-1][j-1] == 0 && tabDepart[i-1][j+1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][0] = 7;
                        }
                        else if(tabDepart[i-1][j-1] == 1 && tabDepart[i-1][j+1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][0] = 1;
                        }
                    }
                    if(tabDepart[i-2][j] == 1) //Proche
                    {
                        if(tabDepart[i-1][j-1] == 0 && tabDepart[i-1][j+1] == 1) //Gauche
                        {
                            adressesImages[tabMid[i][j]][0] = 4;
                        }
                        else if(tabDepart[i-1][j-1] == 1 && tabDepart[i-1][j+1] == 0) //Droite
                        {
                            adressesImages[tabMid[i][j]][0] = 2;
                        }
                        else if(tabDepart[i-1][j-1] == 0 && tabDepart[i-1][j+1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][0] = 6;
                        }
                        else if(tabDepart[i-1][j-1] == 1 && tabDepart[i-1][j+1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][0] = 0;
                        }
                    }
                }
            }

            if(tabDepart[i+1][j] == 1) //On regarde au Sud
            {
                adressesImages[tabMid[i][j]][2] = 8; //Très proche
            }
            else
            {
                if(i<18)
                {

                    if(tabDepart[i+2][j] == 0) //Loin
                    {
                        if(tabDepart[i+1][j+1] == 0 && tabDepart[i+1][j-1] == 1) //Gauche
                        {
                            adressesImages[tabMid[i][j]][2] = 5;
                        }
                        else if(tabDepart[i+1][j+1] == 1 && tabDepart[i+1][j-1] == 0) //Droite
                        {
                            adressesImages[tabMid[i][j]][2] = 3;
                        }
                        else if(tabDepart[i+1][j+1] == 0 && tabDepart[i+1][j-1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][2] = 7;
                        }
                        else if(tabDepart[i+1][j+1] == 1 && tabDepart[i+1][j-1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][2] = 1;
                        }
                    }
                    if(tabDepart[i+2][j] == 1) //Proche
                    {
                        if(tabDepart[i+1][j+1] == 0 && tabDepart[i+1][j-1] == 1) //Gauche
                        {
                            adressesImages[tabMid[i][j]][2] = 4;
                        }
                        else if(tabDepart[i+1][j+1] == 1 && tabDepart[i+1][j-1] == 0) //Droite
                        {
                            adressesImages[tabMid[i][j]][2] = 2;
                        }
                        else if(tabDepart[i+1][j+1] == 0 && tabDepart[i+1][j-1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][2] = 6;
                        }
                        else if(tabDepart[i+1][j+1] == 1 && tabDepart[i+1][j-1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][2] = 0;
                        }
                    }
                }
            }

            if(tabDepart[i][j-1] == 1) //On regarde à l'Ouest
            {
                adressesImages[tabMid[i][j]][1] = 8; //Très proche
            }
            else
            {
                if(j>1)
                {

                    if(tabDepart[i][j-2] == 0) //Loin
                    {
                        if(tabDepart[i-1][j-1] == 1 && tabDepart[i+1][j-1] == 0) //Gauche
                        {
                            adressesImages[tabMid[i][j]][1] = 5;
                        }
                        else if(tabDepart[i-1][j-1] == 0 && tabDepart[i+1][j-1] == 1) //Droite
                        {
                            adressesImages[tabMid[i][j]][1] = 3;
                        }
                        else if(tabDepart[i-1][j-1] == 0 && tabDepart[i+1][j-1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][1] = 7;
                        }
                        else if(tabDepart[i-1][j-1] == 1 && tabDepart[i+1][j-1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][1] = 1;
                        }
                    }
                    if(tabDepart[i][j-2] == 1) //Proche
                    {
                        if(tabDepart[i-1][j-1] == 1 && tabDepart[i+1][j-1] == 0) //Gauche
                        {
                            adressesImages[tabMid[i][j]][1] = 4;
                        }
                        else if(tabDepart[i-1][j-1] == 0 && tabDepart[i+1][j-1] == 1) //Droite
                        {
                            adressesImages[tabMid[i][j]][1] = 2;
                        }
                        else if(tabDepart[i-1][j-1] == 0 && tabDepart[i+1][j-1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][1] = 6;
                        }
                        else if(tabDepart[i-1][j-1] == 1 && tabDepart[i+1][j-1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][1] = 0;
                        }
                    }
                }
            }

            if(tabDepart[i][j+1] == 1) //On regarde à l'Est
            {
                adressesImages[tabMid[i][j]][3] = 8; //Très proche
            }
            else
            {
                if(j<18)
                {

                    if(tabDepart[i][j+2] == 0) //Loin
                    {
                        if(tabDepart[i-1][j+1] == 0 && tabDepart[i+1][j+1] == 1) //Gauche
                        {
                            adressesImages[tabMid[i][j]][3] = 5;
                        }
                        else if(tabDepart[i-1][j+1] == 1 && tabDepart[i+1][j+1] == 0) //Droite
                        {
                            adressesImages[tabMid[i][j]][3] = 3;
                        }
                        else if(tabDepart[i-1][j+1] == 0 && tabDepart[i+1][j+1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][3] = 7;
                        }
                        else if(tabDepart[i-1][j+1] == 1 && tabDepart[i+1][j+1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][3] = 1;
                        }
                    }
                    if(tabDepart[i][j+2] == 1) //Proche
                    {
                        if(tabDepart[i-1][j+1] == 0 && tabDepart[i+1][j+1] == 1) //Gauche
                        {
                            adressesImages[tabMid[i][j]][3] = 4;
                        }
                        else if(tabDepart[i-1][j+1] == 1 && tabDepart[i+1][j+1] == 0) //Droite
                        {
                            adressesImages[tabMid[i][j]][3] = 2;
                        }
                        else if(tabDepart[i-1][j+1] == 0 && tabDepart[i+1][j+1] == 0) //Gauche et Droite
                        {
                            adressesImages[tabMid[i][j]][3] = 6;
                        }
                        else if(tabDepart[i-1][j+1] == 1 && tabDepart[i+1][j+1] == 1) //Ni Gauche ni Droite
                        {
                            adressesImages[tabMid[i][j]][3] = 0;
                        }
                    }
                }
            }

        }
    }
    /////////////////////////////// Vérification des codes stockés
    /*for(int i=0; i<20; i++)
    {
        for(int j=0; j<20; j++)
        {
            if(tabDepart[i][j] == 0)
            {
                cout << " " << adressesImages[tabMid[i][j]][3] << " ";
            }
            else
            {
                cout << "###";
            }
        }
        cout << endl;
    }*/
}

void posJoueur()
{
    for(int i=1; i<19; i++)
    {
        for(int j=1; j<19; j++)
        {
            if(tabDepart[i][j] == 0)
            {
                positionsJoueur[tabMid[i][j]][0] = i-1;
                positionsJoueur[tabMid[i][j]][1] = j-1;
            }
        }
    }
    /////////////////////// Vérification des codes stockés
    for(int i=0; i<20; i++)
    {
        for(int j=0; j<20; j++)
        {
            if(tabDepart[i][j] == 0)
            {
                cout << "(" << positionsJoueur[tabMid[i][j]][0] << "," << positionsJoueur[tabMid[i][j]][1] << ")";
                if((positionsJoueur[tabMid[i][j]][0] < 10 && !(positionsJoueur[tabMid[i][j]][1] < 10)) || (!(positionsJoueur[tabMid[i][j]][0] < 10) && positionsJoueur[tabMid[i][j]][1] < 10))
                {
                    cout << " ";
                }
                if(positionsJoueur[tabMid[i][j]][0] < 10 && positionsJoueur[tabMid[i][j]][1] < 10)
                {
                    cout << "  ";
                }
            }
            else
            {
                cout << "#######";
            }
        }
        cout << endl;
    }
}

void rassemblementImages()
{
    for(int i=0; i<182; i++)
    {
        adressesImagesMemoire[i][0] = adressesImages[i][0] * 16 + adressesImages[i][1];
        adressesImagesMemoire[i][1] = adressesImages[i][2] * 16 + adressesImages[i][3];
    }
}

void hexaPourMemoire()
{
    for(int i=0; i<182; i++)
    {
        //cout << i << ", ";
        cout << adressesVoisines[i][0] << ", " << adressesVoisines[i][1] << ", " << adressesVoisines[i][2] << ", " << adressesVoisines[i][3] << ", ";
        //cout << adressesImages[i][0] << ", " << adressesImages[i][1] << ", " << adressesImages[i][2] << ", " << adressesImages[i][3] << ", ";
        cout << adressesImagesMemoire[i][0] << ", " << adressesImagesMemoire[i][1] << ", ";
        cout << positionsJoueur[i][0] << ", " << positionsJoueur[i][1];
        if(i<181)
        {
            cout << ", ";
        }
        //cout << endl;
    }
}
