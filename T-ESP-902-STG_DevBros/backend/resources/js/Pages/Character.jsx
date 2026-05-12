import { Head } from '@inertiajs/react';
import CharacterApp from '../character/App';
import '../character/index.css';
import AuthenticationProvider from '../character/context/AuthenticationProvider';
import { MannequinProvider } from '../character/context/MannequinProvider';

export default function Character() {
    return (
        <>
            <Head title="Character" />
            <AuthenticationProvider>
                <MannequinProvider>
                    <CharacterApp />
                </MannequinProvider>
            </AuthenticationProvider>
        </>
    );
}
